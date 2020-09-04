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
            <h4>Sold today: {{this.totalPlayer24hour}}</h4>
            <h4>Total sold: {{this.totalPlayed}}</h4>
          </div>
        </div>
        <div class="game-body-static game-body-3">
          <div class="game-statistics-box game-statistics-bo-1">
            <h2 class="section-title">Past Winners</h2>
            <ul>
              <li v-for="(winner,index) in pastWinners" :key="index">{{ winner }}</li>
            </ul>
          </div>
        </div>
      </div>
      <div class="game-wrapper-single wrapper-stack-2">
        <h1 class="current-jackpot">Current Jackpot</h1>
        <div class="lottery-amount">
          <h1>{{currentReward}} CNR</h1>
        </div>
        <div class="lottery-trigger">
          <h3>Jackpot Triggers In</h3>
          <h1>{{this.countdown}}</h1>
        </div>
        <!-- <h1 class="attention-text">1 Entry Per Wallet Daily</h1> -->
        <div class="lottery-pay-trx-button">
          <h3>Cost to play: 1 Centric Rise (CNR) per entry</h3>
          <div class="lottery-button-top">
            <h4>
              Your Wallet :
              <span>{{accountAddress}}</span>
            </h4>
            <h4>
              Your Wallet Balance:
              <span>{{this.yourBalance}} CNR</span>
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
          <h4>You've entered the jackpot.</h4>
        </div>
      </div>
      <div class="game-wrapper-single wrapper-stack-3">
        <div class="current-players-box">
          <h1>Current Players</h1>
          <div class="player-stastics">
            <table class="player-table">
              <thead>
                <tr>
                  <th>Game#</th>
                  <th>Wallet#</th>
                  <th>Date/Time</th>
                  <th>#tickets</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>21</td>
                  <td>Tt24..Bbrj</td>
                  <td>08-09-20 00:14:32</td>
                  <td>1000</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </section>
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
import TronWebService from "./services/tronweb";
import dayjs from "dayjs";

export default {
  name: "Home",
  components: {},
  data() {
    return {
      players: [],
      createTime: -1,
      endTime: -1,
      currentReward: -1,
      totalWin: -1,
      pastWinners: [],
      totalPlayed: -1,
      totalPlayer24hour: -1,
      yourBalance: -1,
      countdown: -1,
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
    const tronweb = TronWebService.getInstance();
    await tronweb.init();

    this.players = await tronweb.CNRLottoContract.getPlayers().call();
    const createTime = await tronweb.CNRLottoContract.getCreateTime().call();
    const endTime = await tronweb.CNRLottoContract.getEndTime().call();
    this.createTime = dayjs(parseInt(createTime) * 1000).format(
      "DD/MM/YYYY hh:mm:ss"
    );
    this.endTime = dayjs(parseInt(endTime) * 1000).format(
      "DD/MM/YYYY hh:mm:ss"
    );

    if (parseInt(endTime) > 0) {
      this.tick = setInterval(() => {
        this.countdown = dayjs(
          parseInt(parseInt(endTime) - Date.now() / 1000) * 1000
        ).format("DD/MM/YYYY hh:mm:ss");
      }, 1000);
    }

    const balance = await tronweb.CNRTokenContract.balanceOf(
      tronweb.CNRLottoAddress
    ).call();
    const walletBalance = await tronweb.CNRTokenContract.balanceOf(
      this.accountAddress
    ).call();
    this.yourBalance = parseInt(walletBalance.balance) / 10 ** 8;
    this.currentReward = parseInt(balance.balance) / 10 ** 8;
    const vars = await tronweb.CNRLottoContract.vars().call();
    this.totalWin = parseInt(vars.totalWin) / 10 ** 8;
    this.totalPlayed = parseInt(vars.totalPlayed) / 10 ** 8;

    tronweb.CNRLottoContract.Create().watch((err, event) => {
      if (err) return console.error('Error with "LogCreateJob" event:', err);
      if (!event) return;
      if (tronweb.eventTransactions.has(`${event.name}${event.transaction}`))
        return; // check set exists event or not, prevent duplicate event

      tronweb.eventTransactions.add(`${event.name}${event.transaction}`); // add to set

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
        this.countdown = dayjs(
          parseInt(parseInt(endTime) - Date.now() / 1000) * 1000
        ).format("DD/MM/YYYY hh:mm:ss");
      }, 1000);
    });

    tronweb.CNRLottoContract.Play().watch((err, event) => {
      if (err) return console.error('Error with "Play" event:', err);
      if (!event) return;
      if (tronweb.eventTransactions.has(`${event.name}${event.transaction}`))
        return;

      tronweb.eventTransactions.add(`${event.name}${event.transaction}`);

      console.log(event);
      const { player, currentReward } = event.result;
      this.players = [...this.players, player];
      console.log("player array : ", this.players);
      this.currentReward = currentReward / 10 ** 8;
    });

    tronweb.CNRLottoContract.Win().watch((err, event) => {
      if (err) return console.error('Error with "Win" event:', err);
      if (!event) return;
      if (tronweb.eventTransactions.has(`${event.name}${event.transaction}`))
        return;

      tronweb.eventTransactions.add(`${event.name}${event.transaction}`);

      console.log(event);
      const { totalWin } = event.result;
      this.totalWin = totalWin / 10 ** 8;
    });

    const pastEventWins = await tronweb.tronGrid.contract.getEvents(
      tronweb.CNRLottoAddress,
      {
        event_name: "Win",
        min_timestamp: Date.now() - 24 * 60 * 60 * 30 * 1000, // get event win in last month
      }
    );
    console.log("pastEventWins", pastEventWins);
    this.pastWinners = pastEventWins.data.map((it) => {
      return it.result.winner;
    });

    const pastEventPlays = await tronweb.tronGrid.contract.getEvents(
      tronweb.CNRLottoAddress,
      {
        event_name: "Play",
        min_timestamp: Date.now() - 24 * 60 * 60 * 1000, // get event play in last 24 hour
      }
    );

    console.log("pastEventPlays", pastEventPlays);
    this.totalPlayer24hour = pastEventPlays.data.length;
  },
  destroyed() {
    clearInterval(this.tick);
  },
  methods: {
    async play(numberTickets) {
      const tronweb = TronWebService.getInstance();
      const allowance = await tronweb.CNRTokenContract.allowance(
        this.accountAddress,
        tronweb.CNRLottoAddress
      ).call();
      console.log("allowance: ", allowance);

      if (allowance.remaining < 1 * 10 ** 8) {
        const res = await tronweb.CNRTokenContract.balanceOf(
          this.accountAddress
        ).call();
        console.log("balance: ", res);
        await tronweb.CNRTokenContract.approve(
          tronweb.CNRLottoAddress,
          res.balance
        ).send();
      }

      const txid = await tronweb.CNRLottoContract.play(
        this.accountAddress,
        numberTickets
      ).send({
        shouldPollResponse: false,
      });
      console.log("transaction id: ", txid);
    },
    async gameCheck() {
      const tronweb = TronWebService.getInstance();
      const txid = await tronweb.CNRLottoContract.gameCheck().send();
      console.log("transaction id: ", txid);
    },
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
</style>
