
void SimulationThread()
{
  // Run simulations
  while (true)
  {
    // Simulate all IAS values every time.
    for (int j = 0; j < IAS_COUNT; j += incrementIAS)
    {
      int hits = SimulateOnce(j - 80);
      assert(hits < MAX_HITS);
      // These operations are atomic, right?
      results[j][hits]++;
    }
    simCount++;
  }
}

// Simulates one "cast" of Omnislash
int SimulateOnce(int IAS)
{
  int finishedAttacks = 0;
  
  // Attack cooldown that will be left after the next jump
  float remainingCooldown = 0;
  float attackTime = BAT / (1.0 + IAS / 100.0);
  float frontswingTime = FRONTSWING / (1.0 + IAS / 100.0);
  
  for (int slash = 0; slash < MAX_SLASHES; slash++)
  {
    // Time already passed during this slash
    float timeSpent = 0;
    float reactionDelay = random(0.25);
    // Nothing can happen for the remaining attack cooldown or reaction delay, whichever is longer
    timeSpent = max(remainingCooldown, reactionDelay);
    
    while (true)
    {
      // Still have time to complete frontswing?
      if (timeSpent + frontswingTime < 0.4)
      {
        // Yes, attack connects.
        finishedAttacks++;
        // No new attack can be started until attackTime has passed.
        timeSpent += attackTime;
      }
      else break; // Will get interrupted by repositioning.
    }

    if (timeSpent > 0.4) remainingCooldown = timeSpent - 0.4;
    else remainingCooldown = 0;
    // (could just do this using only timeSpent, too, but let's be elaborate) 
  }
  
  return finishedAttacks;
}
