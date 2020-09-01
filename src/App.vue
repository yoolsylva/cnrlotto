<template>
  <div id="app">
    <div v-if="!ready">loading...</div>
    <div v-if="ready">
      <h1>Wallet: {{accountAddress}}</h1>
    </div>

    <div>
      <h3>Create Time: {{createTime}}</h3>
    </div>

    <div>
      <h3>End Time: {{endTime}}</h3>
    </div>

    <div>
      <h3>Current Jackpot: {{currentReward}} CNR</h3>
    </div>

    <div>
      <h3>Current Players:</h3>
      <ul>
        <li v-for="(player,index) in players" :key="index">{{ player }}</li>
      </ul>
    </div>

    <div>
      <h3>Total Paid out: {{totalWin}} CNR</h3>
    </div>

    <div>
      <h3>Tickets Sold</h3>
      <h3>Sold Today: {{this.totalPlayer24hour}}</h3>
      <h3>Total Sold: {{this.totalPlayed}}</h3>
    </div>

    <div>
      <h3>Past Winners:</h3>
      <ul>
        <li v-for="(winner,index) in pastWinners" :key="index">{{ winner }}</li>
      </ul>
    </div>

    <button v-on:click="play">Play</button>
    <button v-on:click="gameCheck">Game Check</button>
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

    const balance = await tronweb.CNRTokenContract.balanceOf(
      tronweb.CNRLottoAddress
    ).call();
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
  destroyed() {},
  methods: {
    async play() {
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
        this.accountAddress
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
