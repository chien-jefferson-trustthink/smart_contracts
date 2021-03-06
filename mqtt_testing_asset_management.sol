// SPDX-License-Identifier: MIT
pragma solidity ^0.5.1;

contract asset_management{
    uint public item_counter = 0;
    Item[] public items;
    
    struct Item{
        string serial_number;
        string asset_type;
        uint date; //mmddyyyy
        uint time; //hhmmss
        string manufacturer;
    }
    
    function addItem(string memory _serial_number, string memory _asset_type, uint _date, 
        uint _time, string memory _manufacturer) public {
        items.push(Item(_serial_number, _asset_type, _date, _time, _manufacturer));
        item_counter++;
    }
    
    function getItemCount() public view returns (uint){
        return item_counter;
    }
}
