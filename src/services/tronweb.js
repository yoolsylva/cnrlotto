import store from '../store';
import TronGrid from 'trongrid';

class TronWebService {
  instance = undefined;
  ready = false;
  tronGrid = undefined;
  CNRLottoContract = undefined;
  CNRTokenContract = undefined;

  eventTransactions = undefined;

  // Shasta
  CNRLottoAddress = "TNbKeJ5XXa6sZB2mEk1PEaVRQ6e7cimBnP"
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

  async init() {
    return new Promise((resolve) => {
      if (this.ready) return resolve();

      this.tick = setInterval(async () => {
        if ((!!window.tronWeb) && (window.tronWeb.ready)) {
          this.tronGrid = new TronGrid(window.tronWeb);

          this.CNRLottoContract = await window.tronWeb.contract().at(this.CNRLottoAddress);
          this.CNRTokenContract = await window.tronWeb.contract().at(this.CNRTokenAddress);

          store.commit('SET_ADDRESS', window.tronWeb.defaultAddress.base58);
          store.commit('SET_READY', true);

          
          this.ready = true;
          clearInterval(this.tick);
          resolve();
        }
      })
    })
  }
}

export default TronWebService;