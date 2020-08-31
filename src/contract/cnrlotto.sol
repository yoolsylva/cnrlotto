pragma solidity ^0.5.4;

contract DailyLottery {
    
    address TokenContractAddress = address(0x41ACFE97538855035203359ACD879299EA88CAF63A); //TRjvDMXxzmmEpULikwK5uXCswJWMVPjD8J  shasta
    // address TokenContractAddress = address(0x41F56AE30D0F87A039485989F5C66E620F4C28CE61);//TYLrbh1pVcx95bop33XQ1iYdh7r3ogEQ8Q CNR Mainnet
    TokenContract token;
    address payable _owner;
    //address payable partner;
    address payable Dev = address(0);
    address payable ROI = address(0);
    uint constant decimals = 8;                        //ether is 18 and sun is 6, cnr is 8
    struct Variables {
        uint256 gameBet;
        uint32 comHouse;
        uint32 comPartner;
        uint32 comDev;
        uint32 comRef;
        uint32 comROI;
        
        uint256 gameTimerSeconds;
        uint256 additionalSeconds;
        uint256 pot;
        uint256 totalWin;
        uint256 totalPlayed;
        uint256 totalFeedROI;
        uint32 totalGames;
        uint256 TimerLimit;
    }
    uint256 startTime;
    uint256 createTime;
    uint256 countdownTimer;
    
    Variables public vars;
    struct MyStats{
        uint32 myPlays;
        uint256 myTotalPlayed;
        uint256 myTotalWin;
    }
    mapping (address => MyStats) mystats;
    
    address payable []  players;
    mapping (address => bool) partners;
    
    event Create(address creator, uint256 createTime,uint256 bet);
    event Win(address creator,address winner, uint256 amount,uint gameNumber);
    
    function play(address payable ref) external {
        require(msg.sender == tx.origin, 'Caller must not be Contract Address');
        require(ref != address(0),"error no ref");
        
        //Check if the contract is allowed to send token on user behalf
        uint256 allowance = token.allowance(msg.sender,address(this));
        require (allowance>=vars.gameBet,'allowance error');
        
        bool sent = token.transferFrom(msg.sender,address(this),vars.gameBet);
        if(!sent) revert();
        
        int32 ret = getTimeLeft();
        require (ret !=0,"need to reveal winner first");
        
        require((now<countdownTimer)||(countdownTimer == 0),"count down Time error");
        mystats[msg.sender].myTotalPlayed += vars.gameBet;
        mystats[msg.sender].myPlays +=1;
        
        if (players.length==0){ //creator
            players.push(msg.sender);
            createTime = now;
            vars.totalGames++;
            emit Create(msg.sender,createTime,vars.gameBet);
            
        } else if (players.length==1){ //trigger player 
            players.push(msg.sender);
            startTime = now;
            countdownTimer = startTime + vars.gameTimerSeconds;
        } else 
        {
            players.push(msg.sender);
            // countdownTimer += vars.additionalSeconds;       //addition seconds removed
            // if (countdownTimer > startTime +vars.TimerLimit) 
            //     countdownTimer = startTime +vars.TimerLimit;
        }
        vars.totalPlayed += vars.gameBet;
        
        uint256 totalCom = 0;
        if (ref != msg.sender) {
            uint256 comRef = vars.comRef * vars.gameBet / 10000;
            if (comRef>0) token.transfer(ref, comRef);
            totalCom += comRef;
        }
        
        uint256 comHouse = vars.comHouse * vars.gameBet / 10000;
        if (comHouse>0) token.transfer(_owner, comHouse);
        totalCom += comHouse;
        
        if (ROI != address(0))
        {
            uint256 _comROI = vars.comROI *vars.gameBet / 10000;
            if (_comROI>0) token.transfer(ROI, _comROI);
            totalCom += _comROI;
            vars.totalFeedROI += _comROI;
        }
        
        if (Dev != address(0))
        {
            uint256 _comDev = vars.comDev * vars.gameBet / 10000;            
            if (_comDev>0) token.transfer(Dev, _comDev);
            totalCom += _comDev;
        }
        
        vars.pot += vars.gameBet - totalCom;
    }
    
    function getTimeLeft() public view returns(int32 _TimeLeft)
    {
        if (countdownTimer == 0)
            return -1;
        if (now<countdownTimer)
            return int32(countdownTimer - now);
        else
            return 0;
    }
    function gameCheck() payable external {
        int32 ret = getTimeLeft();
        if (ret ==0)
            processWinner();
    }
    function processWinner() internal {
        uint256 leng = players.length;
        require(now>=countdownTimer,'now<=countdownTimer');
        require(leng>1);
        
        uint ran = uint(uint256(keccak256(abi.encode(now,leng)))%leng);
            
        address payable winner = players[ran];
        uint256 reward = vars.pot/10000;
        uint256 pot = token.balanceOf(address(this));
        if (pot>=reward){
            bool sent = token.transfer(winner, reward);
            if (sent){
                vars.totalWin += reward;
                mystats[winner].myTotalWin += reward;
    
                emit Win(players[0],winner, reward,vars.totalGames);
            }
        }
        resetGame();
        
    }
    function resetGame() internal {
        startTime = 0;
        createTime = 0;
        countdownTimer = 0;
        vars.pot = token.balanceOf(address(this));
        delete players;
    }
    //Construction
    constructor () public //creation settings
    { 
        //5% to me, 5% to site host, 5% to referrer, 35% to feed ROI

        _owner = msg.sender;
        vars.gameBet = 1*(10**decimals);                   //max amount of a single bet
        vars.comHouse = 500;                                //Com to the House during withdraw 5% /10000
        vars.comDev = 500;                                  //Com to partner 
        vars.comRef = 500;                                  //Ref Com
        vars.comROI = 2500;                                 //ROI Com
                                        
        vars.gameTimerSeconds = 12*60*60;                 //12h timer 
        vars.additionalSeconds = 0;
        vars.pot=0;
        vars.totalWin=0;
        vars.totalPlayed=0;
        vars.totalFeedROI=0;
        
        startTime = 0;
        createTime = 0;
        countdownTimer = 0;
        vars.pot = 0;
        vars.totalGames =0;
        vars.TimerLimit = 5*60; //5 minutes
        
        token = TokenContract(TokenContractAddress);
        
    }
    modifier onlyOwner(){
        require(msg.sender==_owner,'Not Owner');
        _;
    }  
    //Getters Setters
    //mystats uint256 myTotalPlayed;
    //uint256 myTotalWin;
    function getmyTotalPlayed() public view returns(uint256 _myTotalPlayed) {
        return mystats[msg.sender].myTotalPlayed;
    } 
     function getmyPlays() public view returns(uint32 _myPlays) {
        return mystats[msg.sender].myPlays;
    } 
    function getmyTotalWin() public view returns(uint256 _myTotalWin) {
        return mystats[msg.sender].myTotalWin;
    } 
    //totalFeedROI
    function getTotalFeedROI() public view returns(uint256 _totalFeedROI) {
        return vars.totalFeedROI;
    } 
    function getTotalWin() public view returns(uint256 _totalWin) {
        return vars.totalWin;
    } 
    function gettotalPlayed() public view returns(uint256 _totalPlayed) {
        return vars.totalPlayed;
    }
    //totalGames
    function gettotalGames() public view returns(uint256 _totalGames) {
        return vars.totalGames;
    }
    function getPlayers() public view returns(address payable[] memory _players) {
        return players;
    } 
    function getPot() public view returns(uint256 _pot) {
        return vars.pot;
    } 
    function getPlayersLength() public view returns(uint256 _len) {
        return players.length;
    } 
    function getStartTime() public view returns(uint256 _startTime) {
        return startTime;
    } 
    function getCreateTime() public view returns(uint256 _createTime) {
        return createTime;
    }
    function getCountdownTimer() public view returns(uint256 _countdownTimer) {
        return countdownTimer;
    }
    //TimerLimit
    function setTimerLimit(uint256 _TimerLimit) onlyOwner public {
        vars.TimerLimit = _TimerLimit;
    }
    function getTimerLimit() public view returns(uint256 _TimerLimit) {
        return vars.TimerLimit;
    } 
    function setAdditionalSeconds(uint256 _additionalSeconds) onlyOwner public {
        vars.additionalSeconds = _additionalSeconds;
    }
    function getAdditionalSeconds() public view returns(uint256 _additionalSeconds) {
        return vars.additionalSeconds;
    } 
    function setGameTimerSeconds(uint256 _gameTimerSeconds) onlyOwner public {
        vars.gameTimerSeconds = _gameTimerSeconds;
    }
    function getGameTimerSeconds() public view returns(uint256 _gameTimerSeconds) {
        return vars.gameTimerSeconds;
    } 

    function setComROI(uint32 _comROI) onlyOwner public {
        vars.comROI = _comROI;
    }
    function getComROI() public view returns(uint32 _comROI) {
        return vars.comROI;
    }
    function setComDev(uint32 _comDev) onlyOwner public {
        vars.comDev = _comDev;
    }
    function getComDev() public view returns(uint32 _comDev) {
        return vars.comDev;
    } 
    function setComRef(uint32 _comRef) onlyOwner public {
        vars.comRef = _comRef;
    }
    function getComRef() public view returns(uint32 _comRef) {
        return vars.comRef;
    }   
    function setComPartner(uint32 _comPartner) onlyOwner public {
        vars.comPartner = _comPartner;
    }
    function getComPartner() public view returns(uint32 _comPartner) {
        return vars.comPartner;
    }  
    function setComHouse(uint32 _comHouse) onlyOwner public {
        vars.comHouse = _comHouse;
    }
    function getComHouse() public view returns(uint32 _comHouse) {
        return vars.comHouse;
    } 
    function partnerValid(address payable _partner) public view returns (bool _valid){
        if (partners[_partner] == true)
            return true;
        else
            return false;
    }
    function setPartner(address payable _partner,bool pay) onlyOwner public {
        require(_partner != address(0),"non zero");
        partners[_partner] = pay;
    }
    function getPartner(address index) public view returns(bool _exist) {
        return partners[index];
    }  
    function setDev(address payable _dev) onlyOwner public {
        Dev = _dev;
    }
    function getDev() public view returns(address _dev) {
        return Dev;
    }  
    function setROI(address payable _ROI) onlyOwner public {
        ROI = _ROI;
    }
    function getROI() public view returns(address _ROI) {
        return ROI;
    }  
    // function setKeepPot(uint32 _KeepPot) onlyOwner public {
    //     KeepPot = _KeepPot;
    // }
    // function getKeepPot() public view returns(uint256 _KeepPot) {
    //     return KeepPot;
    // }
    //Change gameBet
    function setGameBet(uint256 _gameBet) onlyOwner public {
        vars.gameBet = _gameBet;
    }
    function getGameBet() public view returns(uint256 _gameBet) {
        return vars.gameBet;
    }
    function getOwner() public view returns(address _oAddress) {
        return _owner;
    }
    function getOwnerBalance() public view returns(uint256 _balance) {
        return token.balanceOf(_owner);
    }
    function getContractBalance() public view returns(uint256 _contractBalance) {    
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

contract TokenContract
{
    
    function transferFrom(address, address, uint256) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function balanceOf(address) external view returns (uint256);
    function allowance(address _owner, address _spender) public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}