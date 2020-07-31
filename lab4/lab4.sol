pragma solidity ^0.5.11;

contract AuctionsDubinevich {
    struct Auction{
        address payable beneficiary;
        address  highestBidder;
        uint  highestBid;
        mapping(address => uint) pendingReturns;
        bool ended;
        
        bool exists;
    }
    
    mapping(address => Auction) private auctions;
    int private count;
    address payable private owner;

    event AuctionAdded(address id);
    event BenefitiaryTransfered(address to, uint amount);

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    constructor() public {
        count = 0;
        owner = msg.sender;
    }
    
    function startNewAuction(address id, address payable  _beneficiary) onlyOwner public returns(address){
        require(count != 2 , "more than 2");
        require(!auctions[id].exists , "already exists");
        
        count++;
        auctions[id].exists = true;
        auctions[id].ended = false;
        auctions[id].beneficiary = _beneficiary;
        
        emit AuctionAdded(id);
        return id;
    }

    function bid(address id) public payable {
        require(auctions[id].exists , "no auctione");

        require(!auctions[id].ended, "auctionEnd has already been called.");
        require(
            msg.value > auctions[id].highestBid,
            "There already is a higher bid."
        );
        
        if (auctions[id].highestBid != 0) {
            auctions[id].pendingReturns[auctions[id].highestBidder] += auctions[id].highestBid;
        }
        auctions[id].highestBidder = msg.sender;
        auctions[id].highestBid = msg.value;
    }

    function withdraw(address id) public returns (bool) {
        require(auctions[id].exists , "no auctione");
        
        uint amount = auctions[id].pendingReturns[msg.sender];
        if (amount > 0) {
            auctions[id].pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                auctions[id].pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        emit BenefitiaryTransfered(msg.sender, amount);
        return true;
    }

    function auctionEnd(address id) public {
        require(auctions[id].exists , "no auctione");
        
        require(!auctions[id].ended, "auctionEnd has already been called.");

        auctions[id].ended = true;

        auctions[id].beneficiary.transfer(auctions[id].highestBid);
        count--;
    }
    
    function kill() public {
       if(msg.sender == owner) selfdestruct(owner);
    }
    
    function() external payable { 
        
    }
}