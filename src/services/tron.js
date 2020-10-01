import store from '../store';
import TronGrid from 'trongrid';
// import TronWeb from 'tronweb';

// const TRONGRID_API = "https://api.trongrid.io";

class TronService {
  instance = undefined;
  ready = false;
  address = "-";
  tronGrid = undefined;
  tronWeb = undefined;
  CNRLottoContract = undefined;
  CNRTokenContract = undefined;

  eventTransactions = undefined;

  // Shasta
  // CNRLottoAddress = "TUwuvejicwVN31XTKE12mKzpjNULo3aMsc"
  // CNRTokenAddress = "TRjvDMXxzmmEpULikwK5uXCswJWMVPjD8J"

  // Mainnet
  CNRLottoAddress = "TMfztYHt6n5QcKobSkKKCHJZgLCJHwfcqk"
  CNRTokenAddress = "TYLrbh1pVcx95bop33XQ1iYdh7r3ogEQ8Q"

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
          this.tronWeb = window.tronWeb
          this.tronGrid = new TronGrid(this.tronWeb);
          this.address = window.tronWeb.defaultAddress.base58;

          this.CNRLottoContract = await window.tronWeb.contract().at(this.CNRLottoAddress);
          this.CNRTokenContract = await window.tronWeb.contract().at(this.CNRTokenAddress);

          store.commit('SET_ADDRESS', window.tronWeb.defaultAddress.base58);
          store.commit('SET_READY', true);

          
          this.ready = true;
          clearInterval(this.tick);
          resolve();
        }
      }, 500)
    })
  }
}

export default TronService;