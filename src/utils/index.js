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