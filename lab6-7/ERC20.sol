pragma solidity ^0.5.11;

import "./ERC20Interface.sol";

contract ERC20 is ERC20Interface {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    
    constructor() public {
        _name = "AliakseiCoin";
        _totalSupply = 7 * 1000;
    }
    
    function getTokenName() public view returns(string memory) {
        return _name;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, sub(_allowances[sender][msg.sender], amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = sub(_balances[sender], amount);
        _balances[recipient] = add(_balances[recipient], amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }
    
    function buyTokens(address recipient, uint256 amount) public payable returns(bool) {
        _totalSupply = sub(_totalSupply, amount);
        _balances[recipient] = add(_balances[recipient], amount);
        emit Transfer(address(this), msg.sender, amount);
    }
}