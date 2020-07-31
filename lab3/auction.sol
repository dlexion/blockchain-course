pragma solidity ^0.4.25;

contract AuctionsDubinevich {
    struct Auction{
        address  beneficiary;
        uint  auctionEndTime;
        address  highestBidder;
        uint  highestBid;
        mapping(address => uint) pendingReturns;
        bool ended;
        
        bool exists;
    }
    
    mapping(address => Auction) auctions;
    int count;

    constructor() public {
        count = 0;
    }
    
    function startNewAuction(address id, uint _biddingTime, address  _beneficiary) public{
        if(count == 2) throw;
        if(auctions[id].exists) throw;
        
        count++;
        auctions[id].exists = true;
        auctions[id].auctionEndTime = now + _biddingTime;
        auctions[id].beneficiary = _beneficiary;
    }

    function bid(address id) public payable {
        if(!auctions[id].exists) throw;
        
        require(
            now <= auctions[id].auctionEndTime,
            "Auction already ended."
        );

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
        if(!auctions[id].exists) throw;
        
        uint amount = auctions[id].pendingReturns[msg.sender];
        if (amount > 0) {
            auctions[id].pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                auctions[id].pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd(address id) public {
        if(!auctions[id].exists) throw;
        
        require(now >= auctions[id].auctionEndTime, "Auction not yet ended.");
        require(!auctions[id].ended, "auctionEnd has already been called.");

        auctions[id].ended = true;

        auctions[id].beneficiary.transfer(auctions[id].highestBid);
        count--;
    }
}