// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Tokem {
    error Tokem__InsufficientBalance();
    error Tokem__ZeroAddress();

    string private _name = "Tokem";
    string private _symbol = "TKM";
    uint8 private _decimals = 18;
    uint256 public _totalSupply = 21000000 * (10 ** uint256(_decimals));

    mapping(address account => uint256) private balances;
    mapping(address account => mapping(address spender => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor() {
        balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    function transfer(address _to, uint256 _value) public virtual returns (bool success) {
        address from = msg.sender;
        if (balanceOf(from) < _value) {
            revert Tokem__InsufficientBalance();
        }

        _transfer(from, _to, _value);

        return (true);
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        if (_from == address(0)) {
            revert Tokem__ZeroAddress();
        }

        if (_to == address(0)) {
            revert Tokem__ZeroAddress();
        }

        uint256 fromBalance = balances[_from];

        if (fromBalance < _value) {
            revert Tokem__InsufficientBalance();
        }

        // unchecked disables overflow/underflow checks for arithmetics within the block.
        unchecked {
            balances[_from] = fromBalance - _value;
        }

        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool) {
        if (balances[_from] < _value) {
            revert Tokem__InsufficientBalance();
        }

        uint256 currentAllowance = allowance(msg.sender, _from);

        if (currentAllowance < _value) {
            revert Tokem__InsufficientBalance();
        }

        allowances[msg.sender][_from] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value) internal {
        if (_owner == address(0)) {
            revert Tokem__ZeroAddress();
        }

        if (_spender == address(0)) {
            revert Tokem__ZeroAddress();
        }

        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }
}
