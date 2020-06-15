pragma solidity ^0.5.0;

contract asset_management {
    enum condition_code {DESTROYED, EXPENDED, CERTIFIED, NOT_CERTIFIED}
    event ship_asset_failed (string serial_number, string from_UIC, string to_UIC);
    event transfer_asset_failed(string serial_number, string from_dodacc, string to_dodacc);
    event destroyed_or_expended_missile(string serial_number, uint IUIDtag, condition_code code);
    string[] RDD_list;
    string string_RDD;
    struct asset_attr {
        uint IUIDtag;
        string DODIC;
        string DODACC;
        string stock_number;
        string lot_number;
        string RIC;
        string NSN;
        string account_code;
        string transportation_code;
        string transportation_contract_number;
        string UIC;
        string RDD;
        bool in_transit;
        condition_code code;
    }

    string[] assetList;
    string[] assetsInTransit;
    string[] assetsNotInTransit;
    mapping(string=>asset_attr) assetStruct;
    mapping(string=>uint) assetCountByDODACC;
    mapping(string=>uint) assetCountByUIC;


    function create_asset(uint asset_IUIDtag, string memory serial_number, string memory asset_DODACC, string memory asset_UIC, string memory asset_DODIC, string memory asset_stock_num, string memory asset_lot_num, string memory asset_RIC, string memory asset_NSN,
    string memory asset_account_code, string memory asset_transportation_code)
    public returns (bool success) {
        assetStruct[serial_number].IUIDtag = asset_IUIDtag;
        assetStruct[serial_number].DODACC = asset_DODACC;
        assetStruct[serial_number].UIC = asset_UIC;
        assetStruct[serial_number].DODIC = asset_DODIC;
        assetStruct[serial_number].stock_number = asset_stock_num;
        assetStruct[serial_number].lot_number = asset_lot_num;
        assetStruct[serial_number].RIC = asset_RIC;
        assetStruct[serial_number].NSN = asset_NSN;
        assetStruct[serial_number].account_code = asset_account_code;
        assetStruct[serial_number].transportation_code = asset_transportation_code;
        assetCountByDODACC[asset_DODACC] += 1;
        assetCountByUIC[asset_UIC] +=1;
        return true;
    }

    function create_asset2(string memory serial_number, string memory asset_RDD, string memory asset_transportation_contract_num,
    condition_code asset_condition_code, bool asset_in_transit)
    public returns (bool success) {
        assetStruct[serial_number].transportation_contract_number = asset_transportation_contract_num;
        assetStruct[serial_number].code = asset_condition_code;
        assetStruct[serial_number].RDD = asset_RDD;
        assetStruct[serial_number].in_transit = asset_in_transit;
        if (assetStruct[serial_number].in_transit == true) {
            assetsInTransit.push(serial_number);
        }
        else if (assetStruct[serial_number].in_transit == false) {
            assetsNotInTransit.push(serial_number);
        }
        assetList.push(serial_number);
        return true;
    }


    function transfer_asset(string memory serial_number, string memory from_dodacc, string memory to_dodacc) public returns (bool success) {
        if (keccak256(abi.encodePacked((from_dodacc))) == keccak256(abi.encodePacked((assetStruct[serial_number].DODACC)))) {
            if ((assetStruct[serial_number].code == condition_code.DESTROYED) || (assetStruct[serial_number].code == condition_code.EXPENDED)) {
                emit destroyed_or_expended_missile(serial_number, assetStruct[serial_number].IUIDtag, assetStruct[serial_number].code);
                return false;
            }
            assetStruct[serial_number].DODACC = to_dodacc;
            return true;
        }
       emit transfer_asset_failed(serial_number, from_dodacc, to_dodacc);
       return false;
    }

    function delete_asset(string memory serial_number) public returns(bool success) {
        assetCountByUIC[assetStruct[serial_number].UIC] -= 1;
        assetCountByDODACC[assetStruct[serial_number].DODACC] -=1;
        delete assetStruct[serial_number];
        for (uint i= 0; i < assetList.length-1; i++) {
            if(keccak256(abi.encodePacked(assetList[i])) == keccak256(abi.encodePacked(serial_number))) {
                remove_from_asset_list(i);
                remove_from_asset_RDD_list(i);
            }
        }
        return true;
    }



    function remove_from_asset_list(uint index ) internal returns (bool success) {
        if (index >= assetList.length) return false;
        for (uint i = index; i<assetList.length-1; i++){
            assetList[i] = assetList[i+1];
        }
        assetList.length--;
        return true;
    }

    function get_asset_info(string memory serial_number) public view returns (string memory DODACC,
    string memory account_code, condition_code code, string memory DODIC, string memory UIC, string memory stock_number,
    string memory NSN) {
       return (
              assetStruct[serial_number].DODACC,
              assetStruct[serial_number].account_code,
              assetStruct[serial_number].code,
              assetStruct[serial_number].DODIC,
              assetStruct[serial_number].UIC,
              assetStruct[serial_number].stock_number,
              assetStruct[serial_number].NSN);
   }

   function get_asset_shipping_info (string memory serial_number) public view returns (string memory lot_number, uint IUIDtag,
   string memory UIC, string memory RIC, string memory transportation_code, string memory transportation_contract_number, string memory RDD) {
      return (
      assetStruct[serial_number].lot_number,
      assetStruct[serial_number].IUIDtag,
      assetStruct[serial_number].UIC,
      assetStruct[serial_number].RIC,
      assetStruct[serial_number].transportation_code,
      assetStruct[serial_number].transportation_contract_number,
      assetStruct[serial_number].RDD);
   }


   function ship_asset (string memory serial_number, string memory from_UIC, string memory to_UIC, string memory new_RDD) public returns (bool sucess) {
       if (keccak256(abi.encodePacked((from_UIC))) == keccak256(abi.encodePacked((assetStruct[serial_number].UIC)))) {
           if ((assetStruct[serial_number].code == condition_code.DESTROYED) || (assetStruct[serial_number].code == condition_code.EXPENDED)) {
                emit destroyed_or_expended_missile(serial_number, assetStruct[serial_number].IUIDtag, assetStruct[serial_number].code);
                return false;
            }
           assetStruct[serial_number].UIC = to_UIC;
           assetStruct[serial_number].RDD = new_RDD;
           return true;
       }
       emit ship_asset_failed (serial_number, from_UIC, to_UIC);
       return false;
   }

  function update_condition_code (string memory serial_number, condition_code new_asset_code) public returns (bool success) {
      assetStruct[serial_number].code = new_asset_code;
      return true;
  }

  function get_asset_RDD(string memory serial_number) public view returns (string memory RDD){
      return (assetStruct[serial_number].RDD);
  }

  function concatenate_string(string memory a, string memory b) public pure returns (string memory concat_str) {
    return string(abi.encodePacked(a,":", b));
  }

  function get_asset_transit_status(string memory serial_number) public view returns(bool transit_status) {
      return (assetStruct[serial_number].in_transit);
  }


}
