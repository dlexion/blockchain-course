pragma solidity ^0.5.11;

import "./ERC20.sol";
//"0x49B1B9E6DF23CC8c21afaB280A03e54FB0E54Ef3","1","1574925927","1574935927"

contract Ownable {
    address payable private owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
    
    function getOwnerAddress() public view returns(address payable) {
        return owner;
    }
    
    function transferOwnership(address payable newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract ICO is Ownable {
    uint private _price;
    ERC20 private _token;
    
    uint private _start;
    uint private _end;
    
    event IcoEnded(uint timestamp, uint money);
    
    constructor(address token, uint price, uint start, uint end) public {
        require(start<end);
        require(price>0);
        
        _token = ERC20(token);
        _price = price;
        _start = start;
        _end = end;
    }
    
    function() external { 
        
    }
    
    function isEnded() public view returns(bool){
        return now > _end;
    }
    
    function Finish() public onlyOwner{
        _end = now;
        emit IcoEnded(now, address(this).balance);
        getOwnerAddress().transfer(address(this).balance);
    }
    
    function buyTokens() public payable {
        require(msg.value!=0);
        buy();
    }
    
    function buy() internal {
        require(!isEnded(), "Ico has ended");
        uint tokens = msg.value/_price;
        _token.buyTokens(msg.sender, tokens);
    }
}