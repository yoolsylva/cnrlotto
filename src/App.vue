<template>
  <div id="app">
    <!--[if lte IE 9]>
              <p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade your browser</a> to improve your experience and security.</p>
    <![endif]-->


    <!-- Header Start -->
    <header class="header-area">
      <div class="header-logo">
        <a href>
          <img src="img/logo.png" alt />
        </a>
      </div>
    </header>
    <!-- Header End -->
    <!-- Game Body Area Start -->
    <section class="game-body-wrapper">
      <div class="game-wrapper-single wrapper-stack-1">
        <div class="game-body-static game-body-1">
          <div class="game-statistics-box game-statistics-bo-1">
            <h2 class="section-title">Total Paid Out</h2>
            <h1>{{totalWin}} CNR</h1>
          </div>
        </div>
        <div class="game-body-static game-body-2">
          <div class="game-statistics-box game-statistics-bo-1">
            <h2 class="section-title">Tickets Sold</h2>
            <h4>Sold today: {{totalTicket24hour}}</h4>
            <h4>Total sold: {{totalPlayed}}</h4>
          </div>
        </div>
        <div class="game-body-static game-body-3">
          <div class="game-statistics-box game-statistics-bo-1">
            <h2 class="section-title">Past Winners</h2>
            <!-- <ul>
              <li
                v-for="(winner,index) in pastWinners"
                :key="index"
                style="color: #fff"
              >{{ winner }}</li>
            </ul>-->
            <div class="Winner-stastics">
              <table class="player-table">
                <thead>
                  <tr>
                    <!-- <th>Game#</th> -->
                    <th>Date/Time</th>
                    <th>Wallet#</th>
                    <th>Amount won</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(winner,index) in pastWinners" :key="index">
                    <!-- <td>{{winner.gameNumber}}</td> -->
                    <td>{{winner.timeWin}}</td>
                    <td>{{winner.address}}</td>
                    <td>{{winner.totalWin}}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      <div class="game-wrapper-single wrapper-stack-2">
        <h1 class="current-jackpot">Current Jackpot</h1>
        <div class="lottery-amount">
          <h1>{{currentReward}} CNR</h1>
        </div>
        <div class="lottery-trigger" v-if="countdown === -1">
          <h2>Buy as many tickets as you want!</h2>
        </div>
        <div class="lottery-trigger" v-if="countdown !== -1 && countdown !== 0">
          <h3>Jackpot Triggers In</h3>
          <h1>{{this.countdown}}</h1>
        </div>

        <div class="lottery-trigger" v-if="countdown === 0">
          <h3>Jackpot Ended!</h3>
          <h1>00S</h1>
          <a href="#" class="button-get-winner" @click="gameCheck">Get Winner</a>
        </div>

        <!-- <h1 class="attention-text">1 Entry Per Wallet Daily</h1> -->
        <div class="lottery-pay-trx-button" style="margin-top: 20px">
          <h3>Cost to play: 1 Centric Rise (CNR) per entry</h3>
          <div class="lottery-button-top">
            <h4>
              Your Wallet :
              <span>{{accountAddress}}</span>
            </h4>
            <h4>
              Your Wallet Balance:
              <span>{{yourBalance}} CNR</span>
            </h4>
            <h4 class="yellow-text">How many tickets do you want to buy?</h4>
          </div>
          <div class="lottery-tickets-button">
            <a href="#" v-on:click="play(1)">1</a>
            <a href="#" v-on:click="play(5)">5</a>
            <a href="#" v-on:click="play(10)">10</a>
            <a href="#" v-on:click="play(25)">25</a>
            <a href="#" v-on:click="play(50)">50</a>
            <a href="#" v-on:click="play(100)">100</a>
            <a href="#" v-on:click="play(1000)">1000</a>
          </div>
          <h4 v-if="isEnteredJackpot">You've entered the jackpot.</h4>
          <h4 v-if="isEnteredJackpot === false">Timer starts when there are 1 or more players.</h4>
          <h4 className="earns">REFERRAL LINK:</h4>
          <div class="referral-link">
            <input type="text" readonly v-model="message" />
            <button
              class="trx-btn btn-copy"
              type="button"
              v-clipboard:copy="message"
              v-clipboard:success="onCopy"
              v-clipboard:error="onError"
            >Copy!</button>
            <span  v-if="copied">Copied.</span>
          </div>
          
        </div>
      </div>
      <div class="game-wrapper-single wrapper-stack-3">
        <div class="current-players-box">
          <h1>Current Players</h1>
          <div class="player-stastics">
            <table class="player-table">
              <thead>
                <tr>
                  <th>Game #</th>
                  <th>Wallet #</th>
                  <th>Date/Time</th>
                  <th>Tickets Bought</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(player,index) in playerStats" :key="index">
                  <td>{{currentGameNumber}}</td>
                  <td>{{player.address}}</td>
                  <td>{{player.lastBuyTime}}</td>
                  <td>{{player.numberTicket}}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
    <p align="center">
      <a
        class="smart-contract"
        align="center"
        href="https://shasta.tronscan.org/?_ga=2.264279631.1391848663.1599805570-527983632.1598499554#/contract/TUwuvejicwVN31XTKE12mKzpjNULo3aMsc/code"
        target="_blank"
      >Contract: TUwuvejicwVN31XTKE12mKzpjNULo3aMsc</a>
    </p>
    <footer class="footer-area">
      <div class="social-tab">
        <ul>
          <li>
            <a href>Telegram</a>
          </li>
          <li>
            <a href>Discord</a>
          </li>
          <li>
            <a href>Twitter</a>
          </li>
        </ul>
      </div>
    </footer>
    <!-- Game Body Area End -->
  </div>
</template>

<script>
import TronService from "./services/tron";
import dayjs from "dayjs";
import Cookies from "universal-cookie";
import Swal from "sweetalert2";
import { secondsToDhms, shortenAddress } from "@/utils";

export default {
  name: "Home",
  components: {},
  data() {
    return {
      playerStats: [],
      createTime: -1,
      endTime: -1,
      currentReward: -1,
      totalWin: -1,
      pastWinners: [],
      totalPlayed: -1,
      totalTicket24hour: -1,
      yourBalance: -1,
      countdown: -1,
      ref: null,
      currentGameNumber: -1,
      isEnteredJackpot: false,
      message: "https://cryptoworldgames.com/?ref=TGoghFyYDN8Um1QVmRgCZxp37i6PTBJ8qD",
      copied: false
    };
  },
  computed: {
    accountAddress() {
      return this.$store.state.accountAddress;
    },
    ready() {
      return this.$store.state.ready;
    },
  },
  async created() {
    const tronService = TronService.getInstance();
    await tronService.init();

    const currentGameNumber = await tronService.CNRLottoContract.getTotalGames().call();
    this.currentGameNumber = parseInt(currentGameNumber);

    const players = await tronService.CNRLottoContract.getPlayers().call();
    const filterPlayers = Array.from(new Set(players));

    const playerStats = [];
    for (let i = 0; i < filterPlayers.length; i++) {
      const playerStat = await tronService.CNRLottoContract.getPlayerStat(
        this.currentGameNumber,
        filterPlayers[i]
      ).call();

      playerStats.push({
        address: shortenAddress(
          tronService.tronweb.address.fromHex(filterPlayers[i])
        ),
        lastBuyTime: dayjs(parseInt(playerStat.lastBuyTime) * 1000).format(
          "DD/MM/YYYY hh:mm:ss"
        ),
        numberTicket: parseInt(playerStat.numberTicket),
      });

      if (
        tronService.tronweb.address.fromHex(filterPlayers[i]) ===
        this.accountAddress
      )
        this.isEnteredJackpot = true;
    }
    this.playerStats = playerStats;

    const createTime = await tronService.CNRLottoContract.getCreateTime().call();
    const endTime = await tronService.CNRLottoContract.getEndTime().call();
    this.createTime = dayjs(parseInt(createTime) * 1000).format(
      "DD/MM/YYYY hh:mm:ss"
    );
    this.endTime = dayjs(parseInt(endTime) * 1000).format(
      "DD/MM/YYYY hh:mm:ss"
    );

    if (parseInt(endTime) > 0) {
      this.tick = setInterval(() => {
        const seconds = parseInt(endTime) - parseInt(Date.now() / 1000);
        this.countdown = secondsToDhms(seconds);
        if (seconds <= 0) clearInterval(this.tick);
      }, 1000);
    }

    const balance = await tronService.CNRTokenContract.balanceOf(
      tronService.CNRLottoAddress
    ).call();
    const walletBalance = await tronService.CNRTokenContract.balanceOf(
      this.accountAddress
    ).call();
    this.yourBalance = parseInt(walletBalance.balance) / 10 ** 8;
    this.currentReward = parseInt(balance.balance) / 10 ** 8;
    const vars = await tronService.CNRLottoContract.vars().call();
    this.totalWin = parseInt(vars.totalWin) / 10 ** 8;
    this.totalPlayed = parseInt(vars.totalPlayed) / 10 ** 8;

    tronService.CNRLottoContract.Create().watch((err, event) => {
      if (err) return console.error('Error with "LogCreateJob" event:', err);
      if (!event) return;
      if (
        tronService.eventTransactions.has(`${event.name}${event.transaction}`)
      )
        return; // check set exists event or not, prevent duplicate event

      tronService.eventTransactions.add(`${event.name}${event.transaction}`); // add to set

      console.log(event);
      const { createTime, endTime } = event.result;

      this.createTime = dayjs(parseInt(createTime) * 1000).format(
        "DD/MM/YYYY hh:mm:ss"
      );
      this.endTime = dayjs(parseInt(endTime) * 1000).format(
        "DD/MM/YYYY hh:mm:ss"
      );

      if (this.tick) clearInterval(this.tick);
      this.tick = setInterval(() => {
        const seconds = parseInt(endTime) - parseInt(Date.now() / 1000);
        this.countdown = secondsToDhms(seconds);
        if (seconds <= 0) clearInterval(this.tick);
      }, 1000);
    });

    tronService.CNRLottoContract.Play().watch(async (err, event) => {
      if (err) return console.error('Error with "Play" event:', err);
      if (!event) return;
      if (
        tronService.eventTransactions.has(`${event.name}${event.transaction}`)
      )
        return;

      tronService.eventTransactions.add(`${event.name}${event.transaction}`);

      console.log(event);
      const {
        player,
        currentReward,
        totalPlayed,
        bet,
        totalGames,
      } = event.result;

      this.currentGameNumber = totalGames;

      if (tronService.tronweb.address.fromHex(player) === this.accountAddress)
        this.isEnteredJackpot = true;

      const playerStat = await tronService.CNRLottoContract.getPlayerStat(
        // this.currentGameNumber,
        totalGames,
        player
      ).call();
      const obj = {
        address: shortenAddress(tronService.tronweb.address.fromHex(player)),
        lastBuyTime: dayjs(parseInt(playerStat.lastBuyTime) * 1000).format(
          "DD/MM/YYYY hh:mm:ss"
        ),
        numberTicket: parseInt(playerStat.numberTicket),
      };

      const index = this.playerStats.findIndex(
        (it) => it.address === obj.address
      );
      if (index < 0) {
        this.playerStats = [...this.playerStats, obj];
      } else {
        this.playerStats.splice(index, 1, obj);
      }

      this.currentReward = parseInt(currentReward) / 10 ** 8;
      this.totalPlayed = parseInt(totalPlayed) / 10 ** 8;
      this.totalTicket24hour += parseInt(bet) / 10 ** 8;

      const walletBalance = await tronService.CNRTokenContract.balanceOf(
        this.accountAddress
      ).call();
      this.yourBalance = parseInt(walletBalance.balance) / 10 ** 8;

      Swal.fire({
        position: "top-end",
        icon: "success",
        title: `${obj.address} buy ${bet / 10 ** 8} ticket!`,
        showConfirmButton: false,
        timer: 1500,
      });
    });

    tronService.CNRLottoContract.Win().watch(async (err, event) => {
      if (err) return console.error('Error with "Win" event:', err);
      if (!event) return;
      if (
        tronService.eventTransactions.has(`${event.name}${event.transaction}`)
      )
        return;

      tronService.eventTransactions.add(`${event.name}${event.transaction}`);

      console.log(event);
      const { totalWin, winner, amount, gameNumber, timeWin } = event.result;
      this.totalWin = totalWin / 10 ** 8;
      this.createTime = -1;
      this.endTime = -1;
      this.playerStats = [];
      this.countdown = -1;
      this.currentReward = 0;
      this.isEnteredJackpot = false;

      this.pastWinners = [
        {
          gameNumber: gameNumber,
          address: shortenAddress(tronService.tronweb.address.fromHex(winner)),
          totalWin: parseInt(amount) / 10 ** 8,
          timeWin: dayjs(parseInt(timeWin) * 1000).format(
            "DD/MM/YYYY hh:mm:ss"
          ),
        },
        ...this.pastWinners,
      ];

      const walletBalance = await tronService.CNRTokenContract.balanceOf(
        this.accountAddress
      ).call();
      this.yourBalance = parseInt(walletBalance.balance) / 10 ** 8;

      Swal.fire({
        position: "top-end",
        icon: "success",
        title: `Winner ${shortenAddress(
          tronService.tronweb.address.fromHex(winner)
        )} win Jackpot ${amount / 10 ** 8} CNR!`,
        showConfirmButton: false,
        timer: 10000,
      });
    });

    const pastEventWins = await tronService.tronGrid.contract.getEvents(
      tronService.CNRLottoAddress,
      {
        event_name: "Win",
        min_timestamp: Date.now() - 24 * 60 * 60 * 30 * 1000, // get event win in last month
      }
    );
    console.log("pastEventWins", pastEventWins);

    this.pastWinners = pastEventWins.data
      .map((it) => {
        const winnerInfo = {
          gameNumber: it.result.gameNumber,
          address: shortenAddress(
            tronService.tronweb.address.fromHex(it.result.winner)
          ),
          totalWin: parseInt(it.result.amount) / 10 ** 8,
          timeWin: dayjs(parseInt(it.result.timeWin) * 1000).format(
            "DD/MM/YYYY hh:mm:ss"
          ),
        };
        return winnerInfo;
      })
      .reverse();

    console.log("pastWinner 375 is: ", this.pastWinners);
    const pastEventPlays = await tronService.tronGrid.contract.getEvents(
      tronService.CNRLottoAddress,
      {
        event_name: "Play",
        min_timestamp: Date.now() - 24 * 60 * 60 * 1000, // get event play in last 24 hour
      }
    );

    console.log("pastEventPlays", pastEventPlays);
    let totalTicket24hour = 0;
    pastEventPlays.data.forEach((it) => {
      totalTicket24hour += parseInt(it.result.bet) / 10 ** 8;
    });
    this.totalTicket24hour = totalTicket24hour;

    this.getRef();
  },
  destroyed() {
    clearInterval(this.tick);
  },
  methods: {
    async play(numberTickets) {
      const tronService = TronService.getInstance();
      const endTime = await tronService.CNRLottoContract.getEndTime().call();
      const currentTime = parseInt(Date.now() / 1000);
      if (endTime > 0 && currentTime > endTime) {
        Swal.fire({
          icon: "error",
          title: "Jackpot ended",
          text: "Get winner first and start new Jackpot!",
        });
        return;
      }

      const allowance = await tronService.CNRTokenContract.allowance(
        this.accountAddress,
        tronService.CNRLottoAddress
      ).call();
      console.log("allowance: ", allowance);

      if (allowance.remaining < numberTickets * 10 ** 8) {
        const res = await tronService.CNRTokenContract.balanceOf(
          this.accountAddress
        ).call();
        console.log("balance: ", res);
        await tronService.CNRTokenContract.approve(
          tronService.CNRLottoAddress,
          res.balance
        ).send();
      }

      await tronService.CNRLottoContract.play(numberTickets, this.ref).send({
        shouldPollResponse: true,
      });

      // Swal.fire({
      //   icon: "success",
      //   title: "Buy ticket success!",
      //   showConfirmButton: false,
      //   timer: 2000,
      // });
    },
    async gameCheck() {
      const tronService = TronService.getInstance();
      const txid = await tronService.CNRLottoContract.gameCheck().send();
      console.log(txid);
    },
    getRef() {
      const tronService = TronService.getInstance();
      const cookies = new Cookies();
      const cookieref = cookies.get("ref");

      if (tronService.tronweb.isAddress(cookieref)) {
        this.ref = cookieref;
      } else {
        this.ref = this.accountAddress;

        var href = window.location.href;
        var ref = "";

        var n = href.indexOf("ref=");
        if (n > 0) {
          ref = href.substring(n + 4, n + 4 + 34);
        }

        if (tronService.tronweb.isAddress(ref)) {
          cookies.set("ref", ref, {
            path: "/",
            expires: new Date(Date.now() + 31536000),
          });

          this.ref = ref;
        }
      }
    },
    onCopy() {
      this.copied = true;
    },
    onError() {
      alert('Failed to copy texts. Please try again !')
    }
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}

.button-get-winner {
  background: #c7004c;
  border-radius: 50px;
  padding: 10px 30px;
  color: #fff;
  text-decoration: none;
  font-size: 1em;
  margin-bottom: 100px;
}

.smart-contract {
  color: #007bff;
  text-decoration: none;
}

input[type="text"] {
	background: #3b3b3b;
	border: 2px solid #747576;
	height: 25px;
	width: 50%;
	border-radius: 50px;
	padding: 5px 15px;
	color: #fff;
	margin-top: 18px;
  font-size: 16px;
}

.trx-btn {
	background: #9612ee;
	background: -moz-linear-gradient(-45deg, #9612ee 0%, #9b59c7 100%);
	background: -webkit-linear-gradient(-45deg, #9612ee 0%, #9b59c7 100%);
	background: linear-gradient(135deg, #9612ee 0%, #9b59c7 100%);
	font-size: 16px;
	line-height: 16px;
	margin-top: 20px;
	padding: 10px 25px;
	transition: all 0.3s ease 0s;
	-webkit-transition: all 0.3s ease 0s;
	-moz-transition: all 0.3s ease 0s;
	-ms-transition: all 0.3s ease 0s;
	-o-transition: all 0.3s ease 0s;
}

.trx-btn:hover {
	background: #fff;
	color: #3b3b3b;
}

.btn-copy {
  margin: 20px 0px 0px 50px;
  font-weight: 700;
  font-size: 18px;
  color: #fff;
}

span {
  color: red;
  margin-left: 20px;
}

</style>
