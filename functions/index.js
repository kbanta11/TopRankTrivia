const functions = require('firebase-functions');
const helper = require('./helper.js');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();

exports.payoutCompletedLadders = functions.pubsub.schedule('every 5 minutes').onRun( async (context) => {
	console.log('Paying out ladders...');
	await db.collection('ladders').where('is_paid_out', '==', false).where('end_date', '<', new Date()).get().then( async (querySnap) => {
		if (querySnap.docs.length === 0) {
			console.log('No ladders to payout');
		} else {
			querySnap.forEach( async (doc) => {
				let endDate = doc.data().end_date;
				let fee = doc.data().entry_fee;
				let type = doc.data().type;
				console.log('Doc: ' + doc.id + '/End Date: ' + endDate.toDate() + '/Current Date: ' + new Date());
				let gamesList = [];
				await db.collection('games').where('ladder_id', '==', doc.id).get().then( async (gameQuery) => {
					if(gameQuery.docs.length === 0) {
						console.log('No Games for ladder: ' + doc.id);
					} else {
						var paidUsers = [];
						if(type === 'coins') {
							var numGames = gameQuery.docs.length;
							gameQuery.forEach(gameDoc => {
								var game = new helper.Game(gameDoc.data().user_id, gameDoc.data().total_score);
								gamesList.push(game);
							});
							var i = 1;
							gamesList.sort((a, b) => a.score - b.score);
							scores = [];
							var totalPrize = Math.floor((numGames * fee)*0.95);
							if(numGames < 10) {
								//payout only top player 100% of pot
								var game = gamesList[0];
								game.payout = totalPrize;
								game.rank = 1;
								paidUsers.push(game);
							} else if(numGames < 25) {
								//payout top 3 - 15%, 25%, 60%
								[0.6, 0.25, 0.15].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									paidUsers.push(game);
								});
							} else if (numGames < 50) {
								//payout top 5 - 50%, 20%, 15%, 10%, 5%
								[0.5, 0.2, 0.15, 0.1, 0.05].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									paidUsers.push(game);
								});
							} else if (numGames < 100) {
								//payout top 10 - 41.25%, 17.5%, 12%, 8.5%, 5%, 4%, 3.5%, 3%, 2.75%, 2.5%
								[0.4125, 0.175, 0.12, 0.085, 0.05, 0.04, 0.035, 0.03, 0.0275, 0.025].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									paidUsers.push(game);
								}); 
							} else {
								//payout according to formula (min - (top - min)/(rank^alpha))
								var numWinners = Math.floor(numGames*0.25);
								alpha = helper.getFactorPowerLaw(fee, totalPrize, numWinners);
								gamesList.slice(0,numWinners).forEach((gm, index) => {
									payout = helper.getPayout(index + 1, alpha, fee, totalPrize);
									gm.payout = payout;
									gm.rank = index + 1;
									paidUsers.push(gm);
								});
							}
							paidUsers.forEach( async (gm) => {
								//payout user
								await db.collection('users').doc(gm.user).get().then(async (snapshot) => {
									if(snapshot.empty) {
										console.log('User not found');
										return;
									} else {
										let coins = snapshot.data().coins;
										let wins = snapshot.data().laddersWon;
										let placed = snapshot.data().laddersPlaced;
										coins = coins + gm.payout;
										if(gm.rank === 1) {
											wins = wins + 1;
										}
										placed = placed + 1;
										return await db.runTransaction(async t => {
											return await t.update(snapshot.ref, {'coins': coins, 'laddersWon': wins, 'laddersPlaced': placed});
										});
									}
								});
								console.log('Ladder: ' + doc.id + ', Rank: ' + gm.rank + ', User: ' + gm.user + ', Score: ' + gm.totalScore + ', Payout: ' + gm.payout);
							});
						} else {
							//Payout for Bar contests
							numGames = gameQuery.docs.length;
							gameQuery.forEach(gameDoc => {
								var game = new helper.Game(gameDoc.data().user_id, gameDoc.data().total_score);
								gamesList.push(game);
							});
							gamesList.sort((a, b) => a.score - b.score);
							if(numGames < 25) {
								//winner takes 5x buy in
								var gm = gamesList[0];
								gm.payout = fee*5;
								gm.rank = 1;
								paidUsers.push(gm);
							} else if (numGames < 100) {
								//winner takes 6x buy in, 2nd gets 3x buyin, 3rd gets 1x buyin
								[6, 3, 1].forEach((multiple, index) => {
									var gm = gamesList[index];
									gm.payout = fee*multiple;
									gm.rank = index + 1;
									paidUsers.push(gm);
								});
							} else if (numGames < 250) {
								//winner takes 7x buyin, 2nd gets 4x buyin, 3rd gets 2x buyin, 4th and 5th get 1x buyin
								[7,4,2,1,1].forEach((multiple, index) => {
									var gm = gamesList[index];
									gm.payout = fee*multiple;
									gm.rank = index + 1;
									paidUsers.push(gm);
								});
							} else {
								//winner takes 10x buyin, 2nd gets 7x buyin, 3rd gets 5x buyin, 4th gets 4x buyin 5th gets 4x buyin, 
								//6th 7th and 8th get 3x buyin, 9th and 10th get 2x buy, rest of top 10% get buyin back
								var numWin = Math.floor(numGames*0.1);
								gamesList.slice(0, numWin).forEach((gm, index) => {
									rank = index + 1;
									if(rank === 1) {
										gm.payout = fee*10;
										gm.rank = rank;
									} else if(rank === 2) {
										gm.payout = fee*7;
										gm.rank = rank;
									} else if(rank === 3) {
										gm.payout = fee*5;
										gm.rank = rank;
									} else if(rank === 4 || rank === 5) {
										gm.payout = fee*4;
										gm.rank = rank;
									} else if(rank === 6 || rank === 7 || rank === 8) {
										gm.payout = fee*3;
										gm.rank = rank;
									} else if(rank === 9 || rank === 10) {
										gm.payout = fee*2;
										gm.rank = rank;
									} else {
										gm.payout = fee;
										gm.rank = rank;
									}
									paidUsers.push(gm);
								});
								paidUsers.forEach( async (gm) => {
									//payout user
									await db.collection('users').doc(gm.user).get().then(async (snapshot) => {
										if(snapshot.empty) {
											console.log('User not found');
											return;
										} else {
											let bars = snapshot.data().bars;
											let wins = snapshot.data().laddersWon;
											let placed = snapshot.data().laddersPlaced;
											bars = bars + gm.payout;
											if(gm.rank === 1) {
												wins = wins + 1;
											}
											placed = placed + 1;
											return await db.runTransaction(async t => {
												return await t.update(snapshot.ref, {'bars': bars, 'laddersWon': wins, 'laddersPlaced': placed});
											});
										}
									});
									console.log('Bar Ladder: ' + doc.id + ', Rank: ' + gm.rank + ', User: ' + gm.user + ', Score: ' + gm.totalScore + ', Payout: ' + gm.payout);
								});
							}
						}
					}
					//set ladder in firebase to is_paid_out = true
					return await db.runTransaction(async tr => {
						console.log('Ladder paid out: ' + doc.id);
						return await tr.update(doc.ref, {'is_paid_out': true});
					});
				}).catch(error => {
					console.log('Error with getting games: ' + error);
				});
			});
		}
		console.log('Snap: ' + querySnap);
		return 1;
	});
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
