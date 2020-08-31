<template>
  <div id="app">
    <div v-if="!ready">loading...</div>
    <div v-if="ready">
      <h1>Wallet: {{accountAddress}}</h1>
      <div id="nav">
        <router-link to="/">Home</router-link>|
        <router-link to="/about">About</router-link>
      </div>
      <router-view />
    </div>
  </div>
</template>

<script>
import TronWebService from "./services/tronweb";

export default {
  name: "Home",
  components: {},
  data() {
    return {};
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
    tronweb.init();
  },
  destroyed() {},
  methods: {},
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
