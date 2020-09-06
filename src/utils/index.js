import bs58 from 'bs58';

export function ipfsHashToBytes32(ipfs_hash) {
  var h = bs58.decode(ipfs_hash).toString('hex').replace(/^1220/, '');
  if (h.length != 64) {
      console.log('invalid ipfs format', ipfs_hash, h);
      return null;
  }
  return '0x' + h;
}

export function bytes32ToIPFSHash(hash_hex) {
  //console.log('bytes32ToIPFSHash starts with hash_buffer', hash_hex.replace(/^0x/, ''));
  if(!hash_hex.startsWith('0x')) hash_hex = '0x' + hash_hex;
  var buf = new Buffer(hash_hex.replace(/^0x/, '1220'), 'hex')
  return bs58.encode(buf)
}

export function shortenAddress(address) {
  return address.substr(0, 5) + "..." + address.substr(address.length - 5, address.length)
}

export function secondsToDhms(seconds) {
  seconds = Number(seconds);
  if(seconds <= 0) return 0;
  
  var d = Math.floor(seconds / (3600 * 24));
  var h = Math.floor((seconds % (3600 * 24)) / 3600);
  var m = Math.floor((seconds % 3600) / 60);
  var s = Math.floor(seconds % 60);

  var dDisplay = d > 0 ? d + "D : " : "";
  var hDisplay = h > 0 ? h + "H : " : "";
  var mDisplay = m > 0 ? m + "M : " : "";
  var sDisplay = s > 0 ? s + "S" : "00S";
  return dDisplay + hDisplay + mDisplay + sDisplay;
}