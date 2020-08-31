import store from '../store';

class TronWebService {
  instance = undefined;
  ready = false;
  CNRLottoContract = undefined;
  CNRTokenContract = undefined;

  eventTransactions = undefined;

  // Shasta
  CNRLottoAddress = ""
  CNRTokenAddress = "TRjvDMXxzmmEpULikwK5uXCswJWMVPjD8J"

  static getInstance() {
    if (!this.instance) {
      this.instance = new TronWebService();
    }
    return this.instance;
  }

  constructor() {
    this.eventTransactions = new Set();
  }

  init() {
    if (this.ready) return;

    this.tick = setInterval(async () => {
      if ((!!window.tronWeb) && (window.tronWeb.ready)) {
        this.CNRLottoContract = await window.tronWeb.contract().at(this.CNRLottoAddress);
        this.CNRTokenContract = await window.tronWeb.contract().at(this.CNRTokenAddress);

        store.commit('SET_ADDRESS', window.tronWeb.defaultAddress.base58);
        store.commit('READY', true);

        this.ready = true;
        clearInterval(this.tick);
      }
    })
  }

  getAccountAddr() {
    if (!this.tronwebReady) return "";
    return window.tronWeb.defaultAddress.base58;
  }
}

export default TronWebService;