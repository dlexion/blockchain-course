pragma solidity ^0.5.11;

import "./DateTime.sol";

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

contract Clinic is Ownable {
    //0xe758814E986dA76C158aA90E8Cbc4f6e98b1Fcc5
    address payable private _clinic;
    uint256 private _commission;
    DateTime private _date;
    
    mapping(uint256 => bool) doctors;
    
    mapping(uint256 => Appointment) appointments;
    uint256[] appointmentIds;
    
    struct Appointment {
        uint256 timestamp;
        uint256 doctorId;
        address patient;
        
        bool canceled;
    }
        
    constructor(address payable clinic, uint256 commission) public {
        _clinic = clinic;
        _commission = commission * 1000000000000000000; // to ether
        _date = new DateTime();
    }
    
    //events
    event CommissionTransfered(address id, uint amount);
    event AppointmentCreated(uint doctorId, uint timestamp, address patient);
    event AppointmentCanceled(uint doctorId, uint timestamp, address patient);
    
    //modifiers
    modifier doctorExists(uint256 doctorId) {
        require(doctors[doctorId] == true, "There is no such doctor");
        _;
    }
    
    modifier onlyDayAfter(uint8 day, uint8 month, uint16 year) {
        require(dayAfterFromNow(day, month, year), "Wrong date");
        _;
    }
    
    /*modifier uniq(uint doctorId, uint8 day, uint8 month, uint16 year, uint8 hour, uint8 minute) {
        for(uint i = 0; i < appointmentIds.length; i++){
            require(appointments[i].doctorId != doctorId &&
            appointments[i].timestamp != _date.toTimestamp(year, month, day, hour, minute), 
            "Not uniq");
        }
        _;
    }*/
    
    modifier commissionPaid() {
        require(
            msg.value >= _commission,
            "Not enough Ether provided."
        );
        _;
        _clinic.transfer(_commission);
        emit CommissionTransfered(_clinic, _commission);
         if (msg.value > _commission)
            msg.sender.transfer(msg.value - _commission);
    }

    //functions
    function makeAppointment(uint doctorId, uint8 day, uint8 month, uint16 year, uint8 hour, uint8 minute) public payable doctorExists(doctorId) commissionPaid onlyDayAfter(day, month, year) {
        for(uint i = 0; i < appointmentIds.length; i++){
            require(appointments[i].doctorId != doctorId ||
            appointments[i].timestamp != _date.toTimestamp(year, month, day, hour, minute), 
            "Not uniq");
        }
        
        uint _timestamp = _date.toTimestamp(year, month, day, hour, minute);
        
        uint id = appointmentIds.length;
        appointments[id].timestamp = _timestamp;
        appointments[id].doctorId = doctorId;
        appointments[id].patient = msg.sender;
        appointments[id].canceled = false;
        
        appointmentIds.push(id);
        
        emit AppointmentCreated(doctorId, _timestamp, msg.sender);
    }
    
    function cancelAppointment(uint doctorId, uint8 day, uint8 month, uint16 year, uint8 hour, uint8 minute) public doctorExists(doctorId) onlyDayAfter(day, month, year) returns(bool){
        for(uint id = 0; id < appointmentIds.length; id++){
            if(appointments[id].doctorId == doctorId &&
            appointments[id].timestamp == _date.toTimestamp(year, month, day, hour, minute) &&
            appointments[id].canceled == false){
                appointments[id].canceled = true;
                emit AppointmentCanceled(doctorId, appointments[id].timestamp, appointments[id].patient);
                return true;
            }
        }
        return false;
    }
    
    function addDoctor(uint256 id) public onlyOwner {
        doctors[id] = true;
    }
    
    function checkAppointment(address patienAddress,uint doctorId, uint8 day, uint8 month, uint16 year, uint8 hour, uint8 minute) public view returns(bool){
        if(msg.sender != getOwnerAddress()){
            return false;
        }
        
        if(doctors[doctorId] != true){
            return false;
        }
        
        if(!dayAfterFromNow(day, month, year)){
            return false;
        }
    
        for(uint id = 0; id < appointmentIds.length; id++){
            if(appointments[id].doctorId == doctorId &&
            appointments[id].patient == patienAddress &&
            appointments[id].timestamp == _date.toTimestamp(year, month, day, hour, minute) &&
            appointments[id].canceled == false){
                return true;
            }
        }
        return false;
    }
    
    function kill() public onlyOwner {
        selfdestruct(getOwnerAddress());
    }
    
    function dayAfterFromNow(uint8 dayToCheck, uint8 monthToCheck, uint16 YearToCheck) private view returns(bool) {
        uint256 currentTimestamp = now;
        uint8 currentDay = _date.getDay(currentTimestamp);//current.day;
        uint8 currentMonth =  _date.getMonth(currentTimestamp);//current.month;
        uint16 currentYear =  _date.getYear(currentTimestamp);//current.year;
        
        //validate
        if(YearToCheck < 1970 || YearToCheck > 2037){
            return false;
        }
        
        if(monthToCheck > 12){
            return false;
        }
        
        uint daysInMonthToCheck =  _date.getDaysInMonth(monthToCheck, YearToCheck);
        if(dayToCheck > daysInMonthToCheck){
            return false;
        }
        
        //check
        if(dayToCheck == 1) {
            uint256 numberOfDaysInPreviousMonth;
            if(monthToCheck == 1) {
                numberOfDaysInPreviousMonth = _date.getDaysInMonth(12, YearToCheck - 1);
                
                if(YearToCheck - 1 == currentYear && currentMonth == 12 && currentDay == numberOfDaysInPreviousMonth)
                {
                    return true;
                }
            }
            else{
                numberOfDaysInPreviousMonth = _date.getDaysInMonth(monthToCheck - 1, YearToCheck);
                
                if(YearToCheck == currentYear && monthToCheck - 1 == currentMonth && currentDay == numberOfDaysInPreviousMonth){
                    return true;
                }
            }
        }
        else{
            if(YearToCheck == currentYear && monthToCheck == currentMonth && dayToCheck - 1 == currentDay){
                return true;
            }
        }
        
        return false;

        /*uint timestampToCheck = _date.toTimestamp(YearToCheck, monthToCheck, dayToCheck);
        if(timestampToCheck - currentTimestamp < 86400){//day in seconds
            return true;
        }
        
        return false;*/
    }
    
    function() external { 
        
    }
}