pragma solidity ^0.5.0;

contract unit_management {

    struct unit_attr {
        uint quantity;
        uint authorized_quota;
        string UID_code;
        string unit_name;
        string commander_first_name;
        string commander_last_name;
        string dodacc;
    }

    address[] unitList;
    mapping(address=>unit_attr) unitStruct;

    function create_unit(address unit_address, uint unit_quantity, uint unit_quota, string memory unit_UID, string memory unit_commander_first_name, string memory unit_commander_last_name, string memory dodacc_number)
    public returns(bool success) {
        unitStruct[unit_address].quantity = unit_quantity;
        unitStruct[unit_address].authorized_quota = unit_quota;
        unitStruct[unit_address].UID_code = unit_UID;
        unitStruct[unit_address].commander_first_name = unit_commander_first_name;
        unitStruct[unit_address].commander_last_name = unit_commander_last_name;
        unitStruct[unit_address].dodacc = dodacc_number;
        unitList.push(unit_address);
        return true;
    }

    function delete_unit(address unit_address) public returns(bool success) {
        delete unitStruct[unit_address];
        return true;
    }

    function get_unit(address unit_address) public view returns (string memory UID){
       return (unitStruct[unit_address].UID_code);
   }
    function update_unit(address unit_address, uint new_quantity, uint new_quota, string memory new_UID, string memory new_commander_first_name, string memory new_commander_last_name, string memory new_dodacc) public returns(bool success) {
       unitStruct[unit_address].quantity = new_quantity;
        unitStruct[unit_address].authorized_quota = new_quota;
        unitStruct[unit_address].UID_code = new_UID;
        unitStruct[unit_address].commander_first_name = new_commander_first_name;
        unitStruct[unit_address].commander_last_name = new_commander_last_name;
        unitStruct[unit_address].dodacc = new_dodacc;
       return true;
   }

   function count_assets(address unit_address) public view returns(uint num_assets) {
       return (unitStruct[unit_address].quantity);
   }

   function update_unit_quota(address unit_address, uint new_quota) public returns (bool success) {
       unitStruct[unit_address].authorized_quota = new_quota;
       return true;
   }
}
