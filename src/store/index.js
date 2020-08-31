import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    accountAddress: "",
    ready: false,
  },
  mutations: {
    SET_ADDRESS(state, _accountAddress) {
      state.accountAddress = _accountAddress;
    },
    READY(state, _ready) {
      state.read = _ready;
    },
  },
  actions: {
  },
  modules: {
  }
})
