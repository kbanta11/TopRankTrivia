module.exports = {
  getPayout: function(rank, alpha, minPrize, totalPrize) {
    topPrize = 0.125 * totalPrize;
    console.log(Math.pow(rank, alpha) + '/' + alpha);
    return Math.floor(minPrize + (topPrize - minPrize)/Math.pow(rank, alpha));
  },
  getPowerLawSum: function(lowPrize, totalPrize, numWinners, alpha) {
    total = 0;
    topPrize = totalPrize * 0.125;
    for(i = 1; i <= numWinners; i++) {
      thisPrize = lowPrize + ((topPrize - lowPrize)/Math.pow(i, alpha));
      total = total + thisPrize;
      //console.log('This Prize: ');
    }
    return total;
  },
  getFactorPowerLaw: function(lowPrize, totalPrize, numWinners) {
    alpha = 0.0000000001;
    minAlpha = 0;
    maxAlpha = 10;
    total = getPowerLawSum(lowPrize, totalPrize, numWinners, alpha);
    iterations = 0;
    while(Math.floor(total) !== totalPrize) {
      if(total > totalPrize) {
        minAlpha = alpha;
        alpha = alpha + ((maxAlpha - alpha)/2);
      } else {
        maxAlpha = alpha;
        alpha = alpha - ((alpha - minAlpha)/2);
      }
      total = getPowerLawSum(lowPrize, totalPrize, numWinners, alpha);
      iterations = iterations + 1;
      if(iterations > 5000000) {
        return null;
      }
      //console.log('Alpha: ' + alpha + '/Total: ' + total + '/Target: ' + totalPrize);
    }
    return alpha;
  },
  Game: class {
    constructor(userId, score) {
      this.user = userId;
      this.totalScore = score;
    }
  },
  UserOld: class {
    constructor(userId, coins, bars, wins, placed) {
      this.userId = userId;
      this.coins = coins;
      this.bars = bars;
      this.wins = wins;
      this.placed = placed;
      this.messages = {};
    }
  },
  User: class {
    constructor(userId) {
      this.userId = userId;
    }
  },
  Ladder: class {
    constructor(ladderId, endDate, entryFee, type, title) {
      this.ladderId = ladderId;
      this.endDate = endDate;
      this.entryFee = entryFee;
      this.type = type;
      this.title = title;
      this.games = [];
    }
  },
  Message: class {
    constructor(ladder, game) {
      this.ladder = ladder;
      this.game = game;
    }
  }
}