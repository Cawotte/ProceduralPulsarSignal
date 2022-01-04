class NoiseData {
  
  int w, h;
  float offsetX, offsetY;
  float amplitude;
  
  float minValue, maxValue;
  float ratio;
  
  float[][] noiseData;
  
  NoiseData( int h, int w, float ratio )
  {
    this.w = w;
    this.h = h;
    this.ratio = ratio;
    SetNewRandomOffset();
    
    noiseData = new float[h][w];
    UpdateNoiseData();
  }
  
  void SetSeed(int seed)
  {
     noiseSeed(seed);
  }
  
  float GetNoise( int line, int segment, float minNoise, float maxNoise )
  {
     float noise = noiseData[line][segment];
     noise = map( noise, 0, amplitude, minNoise, maxNoise );
     
     return noise;
  }
  
  void UpdateNoiseData()
  {
    for (int y = 0; y < h; y++)
    {
       for (int x = 0; x < w; x++)
       {
           // We map to sample on the same area regardless of widght/heigth. Only the precision changes.
          float i = map( x, 0, w, 0, 1);
          float j = map( y, 0, h, 0, 1 * ratio ); //We sample according to screen ratio, to not stretch the results
          
          float noise = sampleNoise(i, j);  //<>//
          noiseData[y][x] = noise;
       }
    }
  }
  
  // Sample the Perlin noise at a coordinate (X, Y), and apply all octaves and extra transformation
  // To alter the output noise.
  // Modify directly this function to tweak the output noise.
  private float sampleNoise(float x, float y)
  {
    //return getSpineNoise( x, y );
    //return getSerpentineMountainsNoise( x, y );
    return getSerpentinePeakNoise( x, y );
    
  }
  
  
  // --- Declupated some cool noise functions to "save" their settings
  private float getSerpentinePeakNoise( float x, float y )
  {
    
    float noise = 0;
    
    // Base column on the middle
    
    noise += sampleNoise( x, y, 3, 25, 5, 0.3 );
    //noise += sampleNoise( x, y, 12, 5, 2, 0.3 );
    
    noise *= serpentineNoiseMultiplier( x, y - 0.1, 3, 0.4, 0.5 );
    noise *= spineCurve( x, 0, 0.3 );
    
    noise *= map( y, 0, 1, 1, 0.9 );
    
    // Add smallish noise to add a more rugged look to everything
    noise += sampleNoise( x, y, 32, 1, 1, 0 );
    noise += sampleNoise( x, y, 32, 0.5, 2, 0.6 );
    noise += sampleNoise( x, y, 128, 0.2, 1, 0 );
    
    this.amplitude = 40;
    
    return noise;
  }
  
  private float getSpineNoise( float x, float y )
  {
    float noise = 0;
    
    // Base column on the middle
    
    //noise = 10;
    noise += sampleNoise( x, y, 2.5, 20, 4, 0.2 );
    noise += sampleNoise( x, y, 8, 3, 2, 0.3 );
    //noise += sampleNoise( x, y, 8, 5, 2, 0.3 );
    
    noise *= spineCurve( x, 0.05, 0.4 );
    
    noise *= serpentineNoiseMultiplier( x, y + 0.1, 3, 0.25, 0.7 );
    //noise *= serpentineNoiseMultiplier( x, y + 0.2, 2, 0.15, 1 );
    
    // Reliefs diminishes when further down
    noise *= map( y, 0, 1, 1, 0.8 );
    
    // Add smallish noise to add a more rugged look to everything
    noise += sampleNoise( x, y, 32, 1, 1, 0 );
    noise += sampleNoise( x, y, 32, 0.5, 2, 0.6 );
    noise += sampleNoise( x, y, 128, 0.2, 1, 0 );
    
    this.amplitude = 40;
    
    return noise;
  }
  
  
  private float getSerpentineMountainsNoise( float x, float y )
  {
    float noise = 0;
    
    // Base column on the middle
    
    noise += sampleNoise( x, y, 3, 12, 4, 0.3 );
    noise += sampleNoise( x, y, 12, 1, 2, 0.3 );
    
    noise *= serpentineNoiseMultiplier( x, y, 2, 0.4, 1 );
    noise *= spineCurve( x, 0.05, 0.4 );
    
    // Add smallish noise to add a more rugged look to everything
    noise += sampleNoise( x, y, 32, 1, 1, 0 );
    noise += sampleNoise( x, y, 32, 0.5, 2, 0.6 );
    noise += sampleNoise( x, y, 128, 0.2, 1, 0 );
    
    this.amplitude = 40;
    
    return noise;
  }
  
  // Get a multiplier for the noise value that result in some serpentine relief shape.
  // It offsets the X value based on the Y height, to change the result of a sin calculation.
  // Recommended value for widthAmp is less than 0.5
  private float serpentineNoiseMultiplier( float x, float y, float frequency, float widthAmp, float amplify )
  {
    x = x - sin( y * PI * frequency ) * widthAmp;
    
    float multiplier = sin ( x * PI ) * ( amplify + sin ( x * PI ) ); //The second factor is just some kind of ² to amplify the relief.
    float maxValue = 1 + amplify;
    
    return map( multiplier, -1, maxValue, 0, maxValue); // Map the multiplier minima to 0.
  }
  
  private float sampleNoise( float x, float y, float frequency, float amp, int octave, float fallOff )
  {
    noiseDetail( octave, fallOff );
    
    return noise( (x + offsetX) * frequency, (y + offsetY) * frequency ) * amp;
  }
  
  private float GetAmplitudeOnDistanceFromMiddle( float x, float minAmplitude, float maxAmplitude )
  {
    float distance = dist( x, 0, w / 2, 0 );
    
    float easeValue = easeInOutSine( map( distance, 0, w / 2, 0, 1 ) );
     //<>//
    float amp = map( easeValue, 0, 1, maxAmplitude, minAmplitude );
    
    return amp;
  }
  
  private void SetNewRandomOffset()
  {
      this.offsetX = random(1024) / 1024;
      this.offsetY = random(1024) / 1024;
  }
}

// Custom spine curve
// Like a cos, except it plateaux on minima/extrema values for longer before returning reverting back.
// HighLenght/Low length are the intervals lenghts on which the value stays at min/max.
// Total must be < 1. Transition time = 1 - plateauxLenght.
float spineCurve( float x, float lowL, float highL )
{
  x = ( x + lowL / 2 ); // Offset x as such 0.5 is the peak.
  x = x % 1; // The function periods on 1.
  
  float transitionL = ( 1 - highL - lowL ) / 2;
  
  float sum = highL + lowL + 2 * transitionL;
  if ( abs(sum - 1) > 0.01 ) //Test equality with 1 with a little marging of rounding errors.
    print( "Spine curve intervals sums doesn't amount to one!");
   
  float value = x;
  // must sums to one
  if ( x <= lowL )
    value = -1;
  else if ( x <= lowL + transitionL )
    value = cos( map( x, lowL, lowL + transitionL, PI, TWO_PI ) );
  else if ( x <= lowL + transitionL + highL )
    value = 1;
  else
    value = cos( map( x, lowL + transitionL + highL, 1, 0, PI) );
    
  return map( value, -1, 1, 0, 1 ); // Remap value to take 0 as minimum.
  
}
// EaseInOutSine between 0 and 1.
float easeInOutSine( float x )
{
  return -(cos(PI * x) - 1) / 2;
}


// EaseInOutSine between 0 and 1.
float easeOutSine( float x )
{
  return sin((PI * x) / 2 );
}
