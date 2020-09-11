import store from '../store';
import TronGrid from 'trongrid';

class TronService {
  instance = undefined;
  ready = false;
  tronGrid = undefined;
  tronweb = undefined;
  CNRLottoContract = undefined;
  CNRTokenContract = undefined;

  eventTransactions = undefined;

  // Shasta
  CNRLottoAddress = "TUwuvejicwVN31XTKE12mKzpjNULo3aMsc"
  CNRTokenAddress = "TRjvDMXxzmmEpULikwK5uXCswJWMVPjD8J"

  static getInstance() {
    if (!this.instance) {
      this.instance = new TronService();
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
          this.tronweb = window.tronWeb;
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

export default TronService;