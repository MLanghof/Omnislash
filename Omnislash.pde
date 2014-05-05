
final float BAT = 1.6;
final float FRONTSWING = 0.33;
final int IAS_COUNT = 400+80 + 1;

final int LEVEL = 3;
final int[] SLASHES = { 3, 6, 9, 1 };
final int MAX_SLASHES = SLASHES[LEVEL];
final int MAX_HITS = round(MAX_SLASHES * 1.3) + 1;

int[][] results;
//float maxResult[];

void setup()
{
  size(560, 400);
  
  
  
  results = new int[IAS_COUNT][MAX_HITS];
  //maxResult = new float[IAS_COUNT];
  for (int i = 0; i < IAS_COUNT; i++)
  {
    results[i] = new int[MAX_HITS];
    //maxResult[i] = 0;
  }
  
}

int simsPerFrame = 1000;
int simCount = 0;

void draw()
{
  println(frameRate);
  
  int incrementIAS = 1;
  float hitIncrement = 20;
  
  for (int i = 0; i < simsPerFrame; i++)
  {
    for (int j = 0; j < IAS_COUNT; j += incrementIAS)
    {
      int hits = SimulateOnce(j - 80);
      assert(hits < MAX_HITS);
      results[j][hits]++;
      //maxResult[j] = max(maxResult[j], results[j][hits]);
    }
    simCount++;
  }
  
  background(255);
  pushMatrix();
  translate(0, height);
  translate(20, -20);
  translate(80, 0);
  
  
  
  float prevAvg = 0;
  for (int i = -80; i <= 400; i += incrementIAS)
  {
    float average = 0;
    for (int j = 0; j < MAX_HITS; j++)
    {
      int hits = results[i+80][j];
      float probability = hits / float(simCount);
      average += j * probability;
      
      noStroke();
      fill(color(255 * (1 - probability)));
      rect(i, -j * hitIncrement, incrementIAS, -hitIncrement);
    }
    
    stroke(color(255, 0, 0));
    line(i-incrementIAS, -prevAvg * hitIncrement, i, -average * hitIncrement);
    prevAvg = average;
  }  
  stroke(0);
  fill(0);
  textAlign(CENTER, TOP);
  textSize(8);
  line(-80 - 10, 0, IAS_COUNT - 80 + 10, 0);
  line(0, 0, 0, -hitIncrement * MAX_HITS + 10);
  
  pushMatrix();
  translate(IAS_COUNT - 80 + 10, 0);
  line(0, 0, -2, -2);
  line(0, 0, -2, 2);
  popMatrix();
  
  for (int i = -80; i <= 400; i += 20)
  {
    line(i, -2, i, 2);
    
    text(str(i), i, 5);
  }
  
  
  popMatrix();
  
  
  textAlign(LEFT, TOP);
  textSize(12);
  text("Simulated: " + str(simCount), 10, 10);
}




int SimulateOnce(int IAS)
{
  int finishedAttacks = 0;
  
  float cooldown = 0;
  float attackTime = BAT / (1.0 + IAS / 100.0);
  float frontswingTime = FRONTSWING / (1.0 + IAS / 100.0);
  
  for (int slash = 0; slash < MAX_SLASHES; slash++)
  {
    float timeSpent = 0;
    timeSpent += cooldown;
    
    // Reaction delay (only gets applied on the first attack of the chain!)
    float reactionDelay = random(0.25);
    while (true)
    {
      // Still have time to complete frontswing?
      if (timeSpent + reactionDelay + frontswingTime < 0.4)
      {
        // Yes, attack connects.
        timeSpent += reactionDelay + attackTime;
        finishedAttacks++;
        // Reaction delay only applies for the first attack.
        reactionDelay = 0;
      }
      else break;
    }
    
    if (timeSpent > 0.4) cooldown = timeSpent - 0.4;
    else cooldown = 0;
    // (could just do this with timeSpent, too, but let's be elaborate) 
  }
  return finishedAttacks;
}
