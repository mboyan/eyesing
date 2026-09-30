//#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER
#define PI 3.14159265358979323846

// ----------------------
// -      UNIFORMS      -
// ----------------------

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iTime;                 // shader playback time (in seconds) (replaces iGlobalTime which is now obsolete)
uniform float     iTimeDelta;            // render time (in seconds)
uniform int       iFrame;                // shader playback frame
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)

// uniform sampler2D heightTexture;
uniform sampler2D remoteDepositTexture;
uniform sampler2D exchangeTexture;
uniform sampler2D noiseTexture;

uniform vec2 windDir;
uniform float hopDist;
uniform float maxHops;

const float grainSize = 1.0 / 16.0;//15.0 / 255.0;//256.0;

const ivec2 offsets[8] = ivec2[8](
    ivec2(1, 0),
    ivec2(1, 1),
    ivec2(0, 1),
    ivec2(-1, 1),
    ivec2(-1, 0),
    ivec2(-1, -1),
    ivec2(0, -1),
    ivec2(1, -1)
);

// const ivec2 offsets[8] = ivec2[8](
//     ivec2(1, 0),
//     ivec2(1, -1),
//     ivec2(0, -1),
//     ivec2(-1, -1),
//     ivec2(-1, 0),
//     ivec2(-1, 1),
//     ivec2(0, 1),
//     ivec2(1, 1)
// );

void main(){
    vec2 st = gl_FragCoord.xy/iResolution.xy;

    float sandHeight = texture2D(exchangeTexture, st).x;

    // Check if site is being eroded by wind
    float erodeWind = 1.0 - step(0.0, -texture2D(remoteDepositTexture, st).x);
    sandHeight -= erodeWind * grainSize;

    // Check if site is being deposited on remotely
    vec2 posCheck;
    int nHopsCheck;
    float depositWind = 0.0;
    for(int i = 0; i < maxHops; ++i)
    {
        posCheck = gl_FragCoord.xy - round((i + 1) * hopDist * windDir);

        nHopsCheck = int(texture2D(remoteDepositTexture, posCheck / iResolution.xy).x * maxHops);

        depositWind += step(0.0, -float(abs(i + 1 - nHopsCheck)));
    }

    sandHeight += depositWind * grainSize;

    // Check if site is being deposited on or eroded by avalanche
    vec2 nbOffset;
    float iCompare;
    vec2 iDiff;
    vec2 exchangeTextureSample = texture2D(exchangeTexture, st).yz;
    float erodeAvalanche = 1.0 - step(0.0, -exchangeTextureSample.x);
    float depositAvalanche = 1.0 - step(0.0, -exchangeTextureSample.y);
    for (int i = 0; i < 8; ++i)
    {
        nbOffset = vec2(offsets[i]);

        // For this neighbour, get the angle index of deposition/erosion
        exchangeTextureSample = texture2D(exchangeTexture, (gl_FragCoord.xy + nbOffset) / iResolution.xy).yz;

        // Erode to this neighbour
        iCompare = round(exchangeTextureSample.y * 8. - 1.);
        erodeAvalanche += step(0.0, -abs(float(i) - mod(iCompare + 4., 8.))) * step(0.0, iCompare);
        // iDiff = nbOffset + vec2(offsets[int(max(0.0, iCompare))]);
        // erodeAvalanche += step(0.0, -abs(iDiff.x)) * step(0.0, -abs(iDiff.y)) * step(0.0, iCompare);
        
        // Deposit from this neighbour
        iCompare = round(exchangeTextureSample.x * 8. - 1.);
        depositAvalanche += step(0.0, -abs(float(i) - mod(iCompare + 4., 8.))) * step(0.0, iCompare);
        // iDiff = nbOffset + vec2(offsets[int(max(0.0, iCompare))]);
        // depositAvalanche += step(0.0, -abs(iDiff.x)) * step(0.0, -abs(iDiff.y)) * step(0.0, iCompare);
    }

    sandHeight += depositAvalanche * grainSize;
    sandHeight -= erodeAvalanche * grainSize;

    // Check gradient
    float nbHeight;
    float heightDiffs[8];
    float negHeightDiff = 0.0;
    float posHeightDiff = 0.0;
    float depositable[8]; // indicates whether neighbour is full and cannot be deposited to
    for (int i = 0; i < 8; ++i)
    {
        nbOffset = vec2(offsets[i]);
        nbHeight = texture2D(exchangeTexture, (gl_FragCoord.xy + nbOffset) / iResolution.xy).x;

        heightDiffs[i] = sandHeight - nbHeight;
        negHeightDiff = max(-heightDiffs[i], negHeightDiff);
        posHeightDiff = max(heightDiffs[i], posHeightDiff);

        depositable[i] = 1.0 - step(1.0, nbHeight);
    }
    float avalancheThresh = 2.0 * grainSize;
    float nbWeightsErode[8];
    float nbWeightsDeposit[8];
    float nbWeightErodeSum = 0.0;
    float nbWeightDepositSum = 0.0;
    for (int i = 0; i < 8; ++i)
    {
        nbWeightsErode[i] = step(0.0, -abs(heightDiffs[i] - posHeightDiff)) * step(avalancheThresh, heightDiffs[i]) * depositable[i];
        nbWeightsDeposit[i] = step(0.0, -abs(-heightDiffs[i] - negHeightDiff)) * step(avalancheThresh, -heightDiffs[i]);
        nbWeightErodeSum += nbWeightsErode[i];
        nbWeightDepositSum += nbWeightsDeposit[i];
    }

    float nbEncode;
    float rndSelErode = texture2D(noiseTexture, st).x;
    float rndSelDeposit = rndSelErode * nbWeightDepositSum;
    rndSelErode *= nbWeightErodeSum;
    float lowErode = 0.0;
    float highErode = 0.0;
    float lowDeposit = 0.0;
    float highDeposit = 0.0;
    float erode, deposit;
    vec2 avalancheIndicator = vec2(0.0);
    for (int i = 0; i < 8; ++i)
    {
        nbEncode = float(i + 1) / 8.0;

        highErode = lowErode + nbWeightsErode[i];
        erode = step(lowErode, rndSelErode) * (1.0 - step(highErode, rndSelErode));
        avalancheIndicator.x = mix(avalancheIndicator.x, mix(avalancheIndicator.x, erode * nbEncode, step(0.0, -avalancheIndicator.x)), erode);     // avalanche due to deposition towards neighbour, should give to this neighbour
        lowErode = highErode;

        highDeposit = lowDeposit + nbWeightsDeposit[i];
        deposit = step(lowDeposit, rndSelDeposit) * (1.0 - step(highDeposit, rndSelDeposit));
        avalancheIndicator.y = mix(avalancheIndicator.y, mix(avalancheIndicator.y, deposit * nbEncode, step(0.0, -avalancheIndicator.y)), deposit); // avalanche due to erosion from neighbour, should take from this neighbour
        lowDeposit = highDeposit;
    }

    gl_FragColor = vec4(sandHeight, avalancheIndicator * (1.0 - step(0.0, - (erodeWind + depositWind + erodeAvalanche + depositAvalanche))), 1.0);
    // gl_FragColor = vec4(sandHeight, avalancheIndicator * (1.0 - step(0.0, - (erodeWind + depositWind))), 1.0);
    // gl_FragColor = vec4(sandHeight, avalancheIndicator, 1.0);
}