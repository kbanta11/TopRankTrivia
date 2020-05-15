const functions = require('firebase-functions');
const helper = require('./helper.js');
const admin = require('firebase-admin');
const util = require('util');
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();

exports.processCompletedLadders = functions.pubsub.schedule('15 * * * *').onRun(async (context) => {
	let ladderList = await db.collection('ladders').where('is_paid_out', '==', false).where('end_date', '<', new Date()).get().then((ladderQuery) => {
		if(ladderQuery.docs.length === 0) {
			console.log('No Ladders To Process');
			return 0;
		} else {
			return ladderQuery.docs.map((ladderDoc) => {
				return new helper.Ladder(ladderDoc.id, ladderDoc.data().end_date, ladderDoc.data().entry_fee, ladderDoc.data().type, ladderDoc.data().title);
			});
		}
	});
	console.log('Number of Ladders: ' + ladderList.length);
	if(ladderList === 0) {
		//console.log('Ladder has no length');
		return;
	}
	ladderList = await Promise.all(ladderList).then((ladderResolved) => {
		return ladderResolved;
	});
	//console.log('Resolved Ladder List: ' + ladderList);
	let allGamePromises = [];
	ladderList.forEach((ladder) => {
		console.log('Ladder: ' + ladder.ladderId);
		let games = db.collection('games').where('ladder_id', '==', ladder.ladderId).get().then((gameQuery) => {
			if(gameQuery.docs.length === 0) {
				console.log('No Games for Ladder: ' + ladder.ladderId);
				return 1;
			} else {
				return gameQuery.docs.map((gameDoc) => {
					let game = new helper.Game(gameDoc.data().user_id, gameDoc.data().total_score);
					game.ladderId = ladder.ladderId;
					return game;
				});
			}
		});
		if(games !== 1) {
			allGamePromises.push(games);	
		}
	});
	resolvedGameList = await Promise.all(allGamePromises).then((results) => {
		//console.log('Results of all game promises: ' + results);
		return results;
	});
	//Get resolved game data for each ladder and calculate rankings and payouts
	let finalLadderList = [];
	resolvedGameList.forEach((ladderGame) => {
		if(ladderGame.length > 0) {
			let ladderGameList = [];
			for(let game of ladderGame) {
				ladderGameList.push(game);
				//console.log('Game user: ' + game.user + '/Score: ' + game.totalScore + '/Ladder: ' + game.ladderId);
			}
			ladderGameList.sort((a, b) => b.totalScore - a.totalScore);
			let ldr = ladderList.find(obj => obj.ladderId === ladderGameList[0].ladderId);
			let totalPrize = Math.floor((ladderGameList.length * ldr.entryFee)*0.95);
			//Need to get payout amount for each game
			if(ldr.type === 'coins') {
				//Paying out for Coin Ladders
				if(ladderGameList.length < 10) {
					//payout only top player 100% of pot
					//let game = ladder.
					ladderGameList[0].payout = totalPrize;
					ladderGameList[0].rank = 1;
					//add user to list of paid out users
				} else if(ladderGamesList.length < 25) {
					//payout top 3 - 15%, 25%, 60%
					[0.6, 0.25, 0.15].forEach((rate, index) => {
						ladderGameList[index].payout = Math.floor(totalPrize * rate);
						ladderGameList[index].rank = index + 1;
					});
				} else if (ladderGameList.length < 50) {
					//payout top 5 - 50%, 20%, 15%, 10%, 5%
					[0.5, 0.2, 0.15, 0.1, 0.05].forEach((rate, index) => {
						ladderGameList[index].payout = Math.floor(totalPrize * rate);
						ladderGameList[index].rank = index + 1;
					});
				} else if (ladderGameList.length < 100) {
					//payout top 10 - 41.25%, 17.5%, 12%, 8.5%, 5%, 4%, 3.5%, 3%, 2.75%, 2.5%
					[0.4125, 0.175, 0.12, 0.085, 0.05, 0.04, 0.035, 0.03, 0.0275, 0.025].forEach((rate, index) => {
						ladderGameList[index].payout = Math.floor(totalPrize * rate);
						ladderGameList[index].rank = index + 1;
					}); 
				} else {
					//payout according to formula (min - (top - min)/(rank^alpha))
					var numWinners = Math.floor(ladderGameList.length*0.25);
					alpha = helper.getFactorPowerLaw(ldr.entryFee, totalPrize, numWinners);
					ladderGamesList.slice(0,numWinners).forEach((gm, index) => {
						payout = helper.getPayout(index + 1, alpha, fee, totalPrize);
						gm.payout = payout;
						gm.rank = index + 1;
						ladderGamesList[index] = gm;
					});
				}
			} else {
				//Paying out for Gold Bar Ladders ----TO DO----
				console.log('Bar Ladder');
			}
			ldr.games = ladderGameList;
			finalLadderList.push(ldr);
			console.log('Ladder for games: ' + ldr.ladderId + '/Scores: ' + ladderGameList.map(a => util.format('Score: %d; Rank: %s; Payout: %s', a.totalScore, a.rank, a.payout)));
		} else {
			console.log('No Games...');
		}
	});
	//Go through each ladder now that games and payouts are added and create user list for all user updates and set ladder to paid
	let batch = db.batch();
	let userList = [];
	if(ladderList.length > 0) {
		//Loop through all ladders
		ladderList.forEach((ladder) => {
			//Check if ladder is in list of final ladders with games and payouts
			let finalLadder = finalLadderList.find((a) => a.ladderId === ladder.ladderId);
			if(finalLadder !== undefined) {
				//Process ladder games and create/add to user objects
				finalLadder.games.forEach((game) => {
					//Check if user already has user object in list, if not create one
					let user = userList.find((a) => a.userId === game.user);
					if(user === undefined) {
						//console.log('User Doesn\'t exist. Creating user');
						user = new helper.User(game.user);
					}
					//console.log('User obj: ' + user);
					//Add coins won this game
					if(ladder.type === 'coins' && game.payout !== undefined) {
						if(user.coins === undefined) {
							user.coins = game.payout;
						} else {
							user.coins = user.coins + game.payout;
						}
					}
					//Add gold bars won this game
					if(ladder.type === 'bars' && game.payout !== undefined) {
						if(user.bars === undefined) {
							user.bars = game.payout;
						} else {
							user.bars = user.bars + game.payout;
						}
					}

					//Increment number of wins if win
					if(game.rank === 1) {
						if(user.wins === undefined) {
							user.wins = 1;
						} else {
							user.wins = user.wins + 1;
						}
					}

					//Incremember number of placements if paid
					if(game.rank !== undefined) {
						if(user.placed === undefined) {
							user.placed = 1;
						} else {
							user.placed = user.placed + 1;
						}
					}

					//Add message for game to message list
					if(user.messages === undefined) {
						let msg  = new helper.Message(ladder, game);
						user.messages = [msg];
					} else {
						let msg  = new helper.Message(ladder, game);
						user.messages.push(msg)
					}
					//console.log(util.format('User %s placed %s on %s ladder (%s) and made %s. User has now made %s coins and %s bars this day on %s wins and %s times placed.', user.userId, game.rank, ladder.title, ladder.ladderId, game.payout, user.coins, user.bars, user.wins, user.placed));
					//Add user to user list
					if(userList.find((a) => a.userId === game.user) === undefined) {
						userList.push(user);
					} else {
						let index = userList.findIndex(u => u.userId === user.userId);
						console.log('Index of user: ' + user);
						userList[index] = user;
					}
				});
			} else {
				console.log('Ladder has no final ladder (no games): ' + ladder.ladderId);
			}
			//Update ladder document to paid out and add to batch
			let ladderRef = db.collection('ladders').doc(ladder.ladderId);
			batch.update(ladderRef, {'is_paid_out': true});
		});
	}
	//Get user promises
	let userPromises = [];
	if(userList.length > 0) {
		userList.forEach((user) => {
			let userProm = db.collection('users').doc(user.userId).get().then((userDoc) => {
				user.prevCoins = userDoc.data().coins;
				user.prevBars = userDoc.data().bars;
				user.prevWins = userDoc.data().laddersWon;
				user.prevPlaced = userDoc.data().laddersPlaced;
				//console.log(util.format('User: %s/Previous coins: %s, coins won: %s/Previous won: %s, new wins: %s/Previous Placed: %s, new placed: %s', user.userId, user.prevCoins, user.coins, user.prevWins, user.wins, user.prevPlaced, user.placed));
				return user;
			});
			userPromises.push(userProm);
		});
		console.log('User Promises: ' + userPromises);
		await Promise.all(userPromises).then((users) => {
			users.forEach((u) => {
				console.log(util.format('User: %s/Prev coins: %s, Coins won: %s, New Coins: %s/Prev Wins: %s, New Wins: %s, Total Wins: %s/Prev Placed: %s, New Placed: %s, Total Placed: %s', u.userId, u.prevCoins, typeof u.coins === "undefined" ? 0 : u.coins, typeof u.coins === "undefined" ? u.prevCoins : u.prevCoins + u.coins, u.prevWins, typeof u.wins === "undefined" ? 0 : u.wins, typeof u.wins === "undefined" ? u.prevWins : u.prevWins + u.wins, u.prevPlaced, typeof u.placed === "undefined" ? 0 : u.placed, typeof u.placed === "undefined" ? u.prevPlaced : u.prevPlaced + u.placed));
				//update user doc with new game stats and coins/bars
				let userRef = db.collection('users').doc(u.userId);
				batch.update(userRef, {
					'coins': typeof u.coins === "undefined" ? u.prevCoins : u.prevCoins + u.coins,
					'bars': typeof u.bars === "undefined" ? u.prevBars : u.prevBars + u.bars,
					'laddersWon': typeof u.wins === "undefined" ? u.prevWins : u.prevWins + u.wins,
					'laddersPlaced': typeof u.placed === "undefined" ? u.prevPlaced : u.prevPlaced + u.placed,
				});
				//add user message doc
				u.messages.forEach(message => {
					let messageRef = userRef.collection('messages').doc();
					let messageText = '';
					if(typeof message.game.rank === "undefined") {
						messageText = util.format('Unfortunately you didn\'t rank in the money this time. The "%s" ladder has ended and your score was not high enough. It was great practice for the next one though! Play again soon!', message.ladder.title);
					} else {
						messageText = util.format('All you do is Win! Win! Win! You\'re a winner in the "%s" ladder. You made %d gold coins for placing #%d! Keep playing, keep answering and keep winning!', message.ladder.title, message.game.payout, message.game.rank);
					}
					batch.set(messageRef, {
						'ladder_id': message.ladder.ladderId,
						'datesent': admin.firestore.Timestamp.now(),
						'ladder_title': message.ladder.title,
						'ladder_end_date': message.ladder.endDate,
						'message_subject': typeof message.game.rank === 'undefined' ? 'Better Luck Next Time' : 'Congratulations!',
						'message': messageText,
						'is_read': false,
					});
				});
			});
			return 0;
		});
	}
	//Commit the batch and update the data
	await batch.commit();
});

//Old Method
/*
exports.payoutCompletedLadders = functions.pubsub.schedule('15 * * * *').onRun((context) => {
	console.log('Paying out ladders...');
	//Get all ladders which haven't been paid out yet and have ended
	let ladderQuery = db.collection('ladders').where('is_paid_out', '==', false).where('end_date', '<', new Date()).get().then((querySnap) => {
		if (querySnap.docs.length === 0) {
			console.log('No ladders to payout');
			return 1;
		} else {
			//Loop through each ladder needed to be paid out
			querySnap.forEach( async (doc) => {
				//Get Ladder Data
				let endDate = doc.data().end_date;
				let fee = doc.data().entry_fee;
				let type = doc.data().type;
				var ladder = new helper.Ladder(doc.id, doc.data().end_date, doc.data().entry_fee, doc.data().type);
				let gamesList = [];
				//get list of all games for current ladder being paid out
				let gamesQuery = await db.collection('games').where('ladder_id', '==', ladder.ladderId).get().then((gameQuery) => {
					if(gameQuery.docs.length === 0) {
						console.log('No Games for ladder: ' + ladder.ladderId);
					} else {
						//Start calculating payouts
						var paidUsers = [];
						//Payout for coin ladders
						if(type === 'coins') {
							var numGames = gameQuery.docs.length;
							//Create Game object and add to games list for every game for this ladder
							gameQuery.forEach(gameDoc => {
								var game = new helper.Game(gameDoc.data().user_id, gameDoc.data().total_score);
								gamesList.push(game);
							});
							var i = 1;
							//sort the list of games by score --need to add secondary sorting by max streak
							gamesList.sort((a, b) => a.score - b.score);
							scores = [];
							//Get total prize pool
							var totalPrize = Math.floor((numGames * fee)*0.95);
							if(numGames < 10) {
								//payout only top player 100% of pot
								var game = gamesList[0];
								game.payout = totalPrize;
								game.rank = 1;
								//add user to list of paid out users
								paidUsers.push(game);
							} else if(numGames < 25) {
								//payout top 3 - 15%, 25%, 60%
								[0.6, 0.25, 0.15].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									//add users to paid users list
									paidUsers.push(game);
								});
							} else if (numGames < 50) {
								//payout top 5 - 50%, 20%, 15%, 10%, 5%
								[0.5, 0.2, 0.15, 0.1, 0.05].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									//add users to paid users list
									paidUsers.push(game);
								});
							} else if (numGames < 100) {
								//payout top 10 - 41.25%, 17.5%, 12%, 8.5%, 5%, 4%, 3.5%, 3%, 2.75%, 2.5%
								[0.4125, 0.175, 0.12, 0.085, 0.05, 0.04, 0.035, 0.03, 0.0275, 0.025].forEach((rate, index) => {
									var game = gamesList[index];
									game.payout = totalPrize*rate;
									game.rank = index + 1;
									//add users to paid users list
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
									//add users to paid users list
									paidUsers.push(gm);
								});
							}
							paidUsers.forEach(async (gm) => {
								//payout user --need to add message/alert for paid users and add paid users
								let userRef = db.collection('users').doc(gm.user);
								let batch = db.batch();
								console.log('Paying user: ' + gm.user);
								let userObj = await userRef.get().then((userSnap) => {
									if(userSnap.empty) {
										console.log('User Not Found: ' + userSnap);
										return 0;
									} else {
										console.log(userSnap.data().coins + '/' + userSnap.data().bars + '/' + userSnap.data().laddersWon + '/' + userSnap.data().laddersPlaced);
										return new helper.UserOld(gm.user, userSnap.data().coins, userSnap.data().bars, userSnap.data().laddersWon, userSnap.data().laddersPlaced);
									}
								});
								//	
								if(userObj !== 0) {
									console.log('User Object Values: ' + userObj.userId + ' /Coins: ' + userObj.coins + '/Bars: ' + userObj.bars + '/Wins: ' + userObj.wins + '/Placed: ' + userObj.placed);
									userObj.coins = userObj.coins + gm.payout;
									userObj.placed = userObj.placed + 1;
									if(gm.rank === 1) {
										userObj.wins = userObj.wins + 1;
									}
									console.log('User Object After Update Values: ' + userObj.userId + ' /Coins: ' + userObj.coins + '/Bars: ' + userObj.bars + '/Wins: ' + userObj.wins + '/Placed: ' + userObj.placed);
									batch.update(userRef, {
										'coins': userObj.coins,
										'bars': userObj.bars,
										'laddersWon': userObj.wins,
										'laddersPlaced': userObj.placed
									});
									//Send user message
									let messageRef = userRef.collection('messages').doc();
									batch.set(messageRef, {
										'ladder_id': ladder.ladderId,
										'datesent': Date(),
										'ladder_end_date': ladder.endDate,
										'message': util.format('Congratulations!\n\nYou\'re a winner! You made %d gold coins for placing #%d in the following ladder: %s. You now have %d gold coins!', gm.payout, gm.rank, ladder.title, userObj.coins),
									});										
								}
								batch.commit();
								console.log('Ladder: ' + ladder.ladderId + ', Rank: ' + gm.rank + ', User: ' + gm.user + ', Score: ' + gm.totalScore + ', Payout: ' + gm.payout);
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
								paidUsers.forEach((gm) => {
									let userRef = db.collection('users').doc(gm.user);
									let batch = db.batch();
									console.log('Paying user: ' + gm.user);
									let userObj = userRef.get().then((userSnap) => {
											if(userSnap.empty) {
												console.log('User Not Found: ' + userSnap);
												return 0;
											} else {
												return new helper.UserOld(gm.user, userSnap.data().coins, userSnap.data().bars, userSnap.data().laddersWon, userSnap.data().laddersPlaced);
											}
										});
									//	
									if(userObj !== 0) {
										userObj.bars = userObj.bars + gm.payout;
										userObj.placed = userObj.placed + 1;
										if(gm.rank === 1) {
											userObj.wins = userObj.wins + 1;
										}
										batch.update(userRef, {
											'coins': userObj.coins,
											'bars': userObj.bars,
											'laddersWon': userObj.wins,
											'laddersPlaced': userObj.placed
										});
										//Send user message
										let messageRef = userRef.collection('messages').doc();
										batch.set(messageRef, {
											'ladder_id': ladder.ladderId,
											'datesent': Date(),
											'ladder_end_date': ladder.endDate,
											'message': util.format('Congratulations!\n\nYou\'re a winner! You made %d gold bars for placing #%d in the following ladder: %s. You now have %d gold bars!', gm.payout, gm.rank, ladder.title, userObj.bars),
										});										
									}
									batch.commit();
									console.log('Ladder: ' + ladder.ladderId + ', Rank: ' + gm.rank + ', User: ' + gm.user + ', Score: ' + gm.totalScore + ', Payout: ' + gm.payout);
								});
							}
						}
					}
					//set ladder in firebase to is_paid_out = true
					return db.runTransaction(async tr => {
						console.log('Ladder paid out: ' + ladder.ladderId);
						return await tr.update(db.collection('ladders').doc(ladder.ladderId), {'is_paid_out': true});
					});
				});
				console.log('Doc: ' + doc.id + '/End Date: ' + endDate.toDate() + '/Current Date: ' + new Date());
				return 0;
			});
		}
		console.log('Snap: ' + querySnap);
		return 0;
	}); 
	return 0;
});
*/
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
