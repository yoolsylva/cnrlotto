pragma solidity ^0.5.4;

contract CNRLotto {
    address TokenContractAddress = address(0x41ACFE97538855035203359ACD879299EA88CAF63A); //TRjvDMXxzmmEpULikwK5uXCswJWMVPjD8J  shasta
    //address TokenContractAddress = address(0x41F56AE30D0F87A039485989F5C66E620F4C28CE61);//TYLrbh1pVcx95bop33XQ1iYdh7r3ogEQ8Q CNR Mainnet
    TokenContract token;
    address payable _owner;
    address ROI = address(0);
    uint constant decimals = 8;                        //ether is 18 and sun is 6, cnr is 8
    struct Variables {
        uint256 gameBet;
        uint32 comHouse;
        uint32 comRef;
        uint32 comROI;
        
        uint256 gameTimerSeconds;
        uint256 additionalSeconds;
        uint256 pot;
        uint256 totalWin;
        uint256 totalPlayed;
        uint256 totalFeedROI;
        uint32 totalGames;
    }
    uint256 createTime;
    uint256 endTime;
    
    Variables public vars;
    struct MyStats{
        uint32 myPlays;
        uint256 myTotalPlayed;
        uint256 myTotalWin;
    }
    mapping (address => MyStats) mystats;
    
    address payable []  players;
    
    event Create(address creator, uint256 createTime, uint256 endTime, uint256 bet);
    event Play(address player, uint256 playTime, uint256 totalPlayer, uint256 bet, uint256 totalPlayed, uint256 currentReward);
    event Win(address creator,address winner, uint256 amount,uint gameNumber);
    
    function play(address ref) external {
        require(msg.sender == tx.origin, 'Caller must not be Contract Address');
        require(ref != address(0),"error no ref");
        
        //Check if the contract is allowed to send token on user behalf
        uint256 allowance = token.allowance(msg.sender,address(this));
        require (allowance>=vars.gameBet,'allowance error');
        
        bool sent = token.transferFrom(msg.sender,address(this),vars.gameBet);
        if(!sent) revert();
        
        int32 ret = getTimeLeft();
        require (ret !=0,"need to reveal winner first");
        require((now<endTime)||(endTime == 0),"game not start");
        
        if (ref != msg.sender) {
            uint256 comRef = vars.comRef * vars.gameBet / 10000;
            if (comRef>0) token.transfer(ref, comRef);
        }
        
        uint256 comHouse = vars.comHouse * vars.gameBet / 10000;
        if (comHouse>0) token.transfer(_owner, comHouse);
        
        if (ROI != address(0)){
            uint256 _comROI = vars.comROI *vars.gameBet / 10000;
            if(ref == msg.sender) _comROI += vars.comRef * vars.gameBet / 10000; // if no ref -> transfer to roi
            
            if (_comROI>0) token.transfer(ROI, _comROI);
            vars.totalFeedROI += _comROI;
        }
        
        mystats[msg.sender].myTotalPlayed += vars.gameBet;
        mystats[msg.sender].myPlays +=1;
        
        if (players.length==0){
            createTime = now;
            endTime = createTime + vars.gameTimerSeconds;
            vars.totalGames++;
            emit Create(msg.sender,createTime,endTime,vars.gameBet);
        } 
        
        vars.totalPlayed += vars.gameBet;
        
        players.push(msg.sender);
        emit Play(msg.sender,now,players.length,vars.gameBet,vars.totalPlayed,token.balanceOf(address(this)));
    }
    
    function getTimeLeft() public view returns(int32){
        if (endTime == 0)
            return -1;
        if (now<endTime)
            return int32(endTime - now);
        else
            return 0;
    }
    
    function gameCheck() external {
        int32 ret = getTimeLeft();
        if (ret ==0)
            processWinner();
    }
    
    function processWinner() internal {
        uint256 leng = players.length;
        require(now>=endTime,'now<=endTime');
        
        uint ran = uint(uint256(keccak256(abi.encode(now,leng)))%leng);
            
        address winner = players[ran];
        uint256 reward = token.balanceOf(address(this));

        bool sent = token.transfer(winner, reward);
        if (sent){
            vars.totalWin += reward;
            mystats[winner].myTotalWin += reward;
    
            emit Win(players[0],winner,reward,vars.totalGames);
        }
        resetGame();
        
    }
    
    function resetGame() internal {
        createTime = 0;
        endTime = 0;
        delete players;
    }
    
    //Construction
    constructor () public //creation settings
    { 
        //5% to me, 5% to site host, 5% to referrer, 35% to feed ROI

        _owner = msg.sender;
        vars.gameBet = 1*(10**decimals);                   //max amount of a single bet
        vars.comHouse = 500;                                //Com to the House during withdraw 5% /10000
        vars.comRef = 500;                                  //Ref Com
        vars.comROI = 1000;                                 //ROI Com
                                        
        vars.gameTimerSeconds = 5*60;                 //5 minutes timer 
        vars.totalWin=0;
        vars.totalPlayed=0;
        vars.totalFeedROI=0;
        
        createTime = 0;
        endTime = 0;
        vars.totalGames = 0;
        
        token = TokenContract(TokenContractAddress);
        
    }
    modifier onlyOwner(){
        require(msg.sender==_owner,'Not Owner');
        _;
    } 
    
    function getMyTotalPlayed() public view returns(uint256) {
        return mystats[msg.sender].myTotalPlayed;
    } 
    
    function getMyPlays() public view returns(uint32) {
        return mystats[msg.sender].myPlays;
    }
    
    function getMyTotalWin() public view returns(uint256) {
        return mystats[msg.sender].myTotalWin;
    } 

    function getTotalFeedROI() public view returns(uint256) {
        return vars.totalFeedROI;
    }
    
    function getTotalWin() public view returns(uint256) {
        return vars.totalWin;
    }
    
    function getTotalPlayed() public view returns(uint256) {
        return vars.totalPlayed;
    }
    
    function getTotalGames() public view returns(uint256) {
        return vars.totalGames;
    }
    
    function getPlayers() public view returns(address payable[] memory) {
        return players;
    }
    
    function getPlayersLength() public view returns(uint256) {
        return players.length;
    }
    
    function getCreateTime() public view returns(uint256) {
        return createTime;
    }
    
    function getEndTime() public view returns(uint256) {
        return endTime;
    }
    
    function setGameTimerSeconds(uint256 _gameTimerSeconds) onlyOwner public {
        vars.gameTimerSeconds = _gameTimerSeconds;
    }
    
    function getGameTimerSeconds() public view returns(uint256) {
        return vars.gameTimerSeconds;
    } 

    function setComROI(uint32 _comROI) onlyOwner public {
        vars.comROI = _comROI;
    }
    
    function getComROI() public view returns(uint32) {
        return vars.comROI;
    }
    
    function setComRef(uint32 _comRef) onlyOwner public {
        vars.comRef = _comRef;
    }
    
    function getComRef() public view returns(uint32) {
        return vars.comRef;
    }
    
    function setComHouse(uint32 _comHouse) onlyOwner public {
        vars.comHouse = _comHouse;
    }
    
    function getComHouse() public view returns(uint32) {
        return vars.comHouse;
    }
    
    function setROI(address  _ROI) onlyOwner public {
        ROI = _ROI;
    }
    
    function getROI() public view returns(address) {
        return ROI;
    }
    
    function setGameBet(uint256 _gameBet) onlyOwner public {
        vars.gameBet = _gameBet;
    }
    
    function getGameBet() public view returns(uint256) {
        return vars.gameBet;
    }
    
    function getOwner() public view returns(address _oAddress) {
        return _owner;
    }
    
    function getOwnerBalance() public view returns(uint256) {
        return token.balanceOf(_owner);
    }
    
    function getContractBalance() public view returns(uint256) {    
        return token.balanceOf(address(this));
    }
    
    //Protect the pool in case of hacking
    function kill() onlyOwner public {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(_owner, balance);
        selfdestruct(_owner);
    }
    
    function transferFund(uint256 amount) onlyOwner public {
        uint256 balance = token.balanceOf(address(this));
        require(amount<=balance,'exceed contract balance');
        token.transfer(_owner, amount);
    }
    function transferOwnership(address payable _newOwner) onlyOwner external {
        require(_newOwner != address(0) && _newOwner != _owner);
        _owner = _newOwner;
    }
}

contract TokenContract {
    function transferFrom(address, address, uint256) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address _owner, address _spender) public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}