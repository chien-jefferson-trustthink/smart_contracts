pragma solidity ^0.5.0;

contract dodacc_management {

    struct dodacc_attr {
        uint quantity;
        uint authorized_quota;
        string DODACC;
        address [] units;
    }

   address[] dodaccList;
   mapping(address=>dodacc_attr) dodaccStruct;

    function create_dodacc(address dodacc_address, uint  dodacc_quantity, uint  dodacc_quota, string memory dodacc_number)
    public returns(bool success) {
        dodaccStruct[dodacc_address].quantity = dodacc_quantity;
        dodaccStruct[dodacc_address].authorized_quota = dodacc_quota;
        dodaccStruct[dodacc_address].DODACC= dodacc_number;
        dodaccList.push(dodacc_address);
        return true;
    }

    function delete_dodacc(address dodacc_address) public returns(bool success) {
        delete dodaccStruct[dodacc_address];
        return true;
    }

   function get_dodacc(address dodacc_address) public view returns (string memory dodacc_number){
       return (dodaccStruct[dodacc_address].DODACC);
   }

   function count_assets(address dodacc_address) public view returns(uint num_assets) {
       return (dodaccStruct[dodacc_address].quantity);
   }

   function update_units(address dodacc_address, address[] memory new_units) public returns(bool success) {
       dodaccStruct[dodacc_address].units = new_units;
       return true;
   }

   function update_wallet(address new_dodacc_address, address dodacc_address) public returns (bool success) {
       dodaccStruct[new_dodacc_address] = dodaccStruct[dodacc_address];
       delete_dodacc(dodacc_address);
       return true;
   }

   function update_dodacc_quota(address dodacc_address, uint new_quota) public returns (bool success) {
       dodaccStruct[dodacc_address].authorized_quota = new_quota;
       return true;
   }

   function append_units(address dodacc_address, address unit_address) public returns (bool success) {
       dodaccStruct[dodacc_address].units.push(unit_address);
       return true;
   }

   function get_units(address dodacc_address) public view returns (address[] memory dodacc_units) {
       return (dodaccStruct[dodacc_address].units);
   }

   function get_dodacc_count() public view returns(uint dodacc_count) {
       return(dodaccList.length);
   }

}
