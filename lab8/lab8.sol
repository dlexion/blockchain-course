pragma solidity ^0.5.12;

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

contract ElectronicCashBox is Ownable {
    struct Ticket{
        bool bought;
        address owner;
    }
    
    struct Event{
        mapping(uint => Ticket) tickets;
        uint[] ticketIds;
        uint ticketPrice;
        uint start;
    }
    
    mapping(uint => Event) events;
    uint[] eventIds;
    
    modifier beforeStart(uint eventId){
        require(events[eventId].start > now, "event started");
        _;
    }
    
    modifier notBought(uint eventId, uint ticketId){
        require(!events[eventId].tickets[ticketId].bought, "already bought");
        _;
    }
    
    modifier ticketPaid(uint eventId) {
        require(
            msg.value >= events[eventId].ticketPrice,
            "Not enough Ether provided."
        );
        _;
        if (msg.value > events[eventId].ticketPrice)
            msg.sender.transfer(msg.value - events[eventId].ticketPrice);
    }
    
    modifier validTicket(uint eventId, uint ticketId){
        require(events[eventId].ticketIds.length >= ticketId, "wrong ticket id");
        _;
    }
    
    modifier validEvent(uint eventId){
        require(eventIds.length >= eventId, "wrong event id");
        _;
    }
    
    event EventCreated(uint id, uint ticketsCount, uint price, uint start);
    
    constructor() public{
        
    }
    
    function createEvent(uint ticketsCount, uint price, uint start) public onlyOwner{
        uint id = eventIds.length;
        events[id].ticketPrice = price;
        events[id].start = start;
        
        for(uint i = 0; i < ticketsCount; i++){
            events[id].ticketIds.push(i);
            events[id].tickets[i].bought = false;
        }
        
        eventIds.push(id);
        
        emit EventCreated(id, ticketsCount, price, start);
    }
    
    function buyTicket(uint eventId, uint ticketId) public payable validEvent(eventId) beforeStart(eventId) validTicket(eventId, ticketId) notBought(eventId, ticketId) ticketPaid(eventId) {
        events[eventId].tickets[ticketId].bought = true;
        events[eventId].tickets[ticketId].owner = msg.sender;
    }
    
    uint[] arr;
    function getAvaliableEvents() public returns(uint[] memory){
        uint[] memory result;
        delete arr;
        
        uint length = eventIds.length;
        for(uint i = 0; i < length; i++){
            if(now < events[i].start){
                arr.push(i);
            }
        }
        
        result = arr;
        return result;
    }
    
    function getAvaliableTickets(uint eventId) public validEvent(eventId) returns(uint[] memory){
        uint[] memory result;
        delete arr;
        
        uint length = events[eventId].ticketIds.length;
        for(uint i = 0; i < length; i++){
            if(events[eventId].tickets[i].bought == false){
                arr.push(i);
            }
        }
        
        result = arr;
        return result;
    }
}