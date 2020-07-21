pragma solidity ^0.5.12;

contract asset_management {
    enum condition_code {OK, DAMAGED, EXPENDED, DESTROYED, LOST, UNKNOWN}

    //asset lifecycle events
    //create/update_handling/update_storage/ship/update_gps/receive/transfer/update_storage/delete - update_condition
    event asset_created(string serial_number, uint asset_IUIDtag, string asset_NSN, condition_code asset_condition_code, int asset_count_total);
    event asset_handling_update(string serial_number, string curr_UIC, string curr_RIC, string curr_account_code, uint asset_count_by_uic);
    event asset_storage_update(string serial_number, string curr_ACC, string curr_lot_number, string curr_stock_number, uint asset_count_by_acc);
    event asset_shipped(string serial_number, string from_UIC, string to_UIC, string new_RDD);
    event asset_transit_update(string serial_number, bool asset_in_transit);
    event asset_gps_shipment_coordinates_update(string serial_number, string gps_coordinates);
    event asset_received(string serial_number, string receiving_UIC, string receiving_RIC, string receiving_account_code, string receiving_ACC);
    event asset_transferred(string serial_number, string from_acc, string to_acc);
    event asset_transfer_failed(string serial_number, string from_acc, string to_acc);
    event asset_condition_code_updated(string serial_number, condition_code asset_condition_code);
    event asset_deleted(string serial_number, int assetCountTotal, string asset_uic , uint asset_count_by_uic, string asset_acc, uint asset_count_by_acc);

    struct asset_attr {
        
        /////////////////////// asset identification, condition, and transit state info ///////////////////////
        // Asset unique identification (IUID)
        uint IUIDtag;

        // National Stock Number of asset
        string NSN;
        
        // Current condition of asset
        condition_code code;

        // Asset indicator if in transit
        bool in_transit;
        ////////////////////////////////////////////////////////////////////////////////////////

        /////////////////////// asset handling info /////////////////////////
        // Unit identification code who either currently has the physical asset or will receive the asset in shipment
        string UIC;

        // A 3-character, alpha-numeric code that uniquely identifies a unit, activity, or organization that requires system ability to route asset transactions or receive asset transactions
        string RIC;

        // Account type with possession of the asset
        string account_code;
        /////////////////////////////////////////////////////////////////////

        /////////////////////// asset storage location info /////////////////////////
        //  Stationary physical location code of asset storage
        string ACC;

        // Lot number where asset is stored, for physical storage
        string lot_number;

        // Stock number of asset on lot, for physical storage
        string stock_number;
        /////////////////////////////////////////////////////////////////////////////

        /////////////////////// asset shipping info /////////////////////////
        //GPS coordinates of asset on shipment route
        string GPS_shipment_coordinates;

        // Code of the type of asset being transported.
        string transportation_code;

        // Contract identifier between the asset shipping and receiving parties
        string transportation_contract_number;

        // Required delivery date of asset
        string RDD;
        ////////////////////////////////////////////////////////////////////////////////////
    }

    int assetCountTotal;
    
    mapping(string=>asset_attr) assetStruct;
    mapping(string=>uint) assetCountByACC;
    mapping(string=>uint) assetCountByUIC;

    constructor() public {
       assetCountTotal = 0;
    }

    function create_new_asset(string memory serial_number, uint asset_IUIDtag, string memory asset_NSN, condition_code asset_condition_code)
    public returns (bool success) {
        assetStruct[serial_number].IUIDtag = asset_IUIDtag;
        assetStruct[serial_number].NSN = asset_NSN;
        assetStruct[serial_number].code = asset_condition_code;
        
        //increment total counter
        assetCountTotal += 1;
        
        //emit created asset
        emit asset_created(serial_number, asset_IUIDtag, asset_NSN, asset_condition_code, assetCountTotal);

        //to complete asset create, update handling and storage
        
        return true;
    }

    function update_asset_in_transit_field(string memory serial_number, bool asset_in_transit)
    public returns (bool success) {
        assetStruct[serial_number].in_transit = asset_in_transit;

        emit asset_transit_update(serial_number, asset_in_transit);

        return true;
    }

    function update_asset_handling(string memory serial_number, string memory curr_UIC, string memory curr_RIC, string memory curr_account_code)
    public returns (bool success) {
        assetStruct[serial_number].UIC = curr_UIC;
        assetStruct[serial_number].RIC = curr_RIC;
        assetStruct[serial_number].account_code = curr_account_code;

        assetCountByUIC[curr_UIC] += 1;

        emit asset_handling_update(serial_number, curr_UIC, curr_RIC, curr_account_code, assetCountByUIC[curr_UIC]);

        return true;
    }

    function update_asset_storage(string memory serial_number, string memory curr_ACC, string memory curr_lot_number, string memory curr_stock_number)
    public returns (bool success) {
        assetStruct[serial_number].ACC = curr_ACC;
        assetStruct[serial_number].lot_number = curr_lot_number;
        assetStruct[serial_number].stock_number = curr_stock_number;

        assetCountByACC[curr_ACC] += 1;

        emit asset_storage_update(serial_number, curr_ACC, curr_lot_number, curr_stock_number, assetCountByACC[curr_ACC]);

        return true;
    }
    
    function ship_asset (string memory serial_number, string memory from_UIC, string memory to_UIC, string memory to_RIC, string memory to_account_code, string memory transportation_code, string memory transportation_contract_number, string memory RDD)
    public returns (bool sucess) {
        assetStruct[serial_number].transportation_code = transportation_code;
        assetStruct[serial_number].transportation_contract_number = transportation_contract_number;
        assetStruct[serial_number].RDD = RDD;

        //clear storage info
        update_asset_storage(serial_number,assetStruct[serial_number].ACC,"","");

        //update handling info
        update_asset_handling(serial_number, to_UIC, to_RIC, to_account_code);

        //update transit, needs gas
        update_asset_in_transit_field(serial_number, true);

        emit asset_shipped(serial_number, from_UIC, to_UIC, RDD);

        return true;
   }

    function update_asset_gps_shipment_coordinates(string memory serial_number, string memory gps_coordinates)
    public returns (bool success) {
        assetStruct[serial_number].GPS_shipment_coordinates = gps_coordinates;
        emit asset_gps_shipment_coordinates_update(serial_number, gps_coordinates);

        return true;
    }

    //NEEDS 100K GAS
    function receive_asset(string memory serial_number, string memory receiving_UIC, string memory receiving_RIC, string memory receiving_account_code, string memory receiving_ACC)
    public returns (bool success) {

        //clear RDD
        assetStruct[serial_number].RDD = "";

        //update ACC
        transfer_asset(serial_number, assetStruct[serial_number].ACC, receiving_ACC);
        
        //update transit, needs gas
        update_asset_in_transit_field(serial_number, false);
        
        emit asset_received(serial_number, receiving_UIC, receiving_RIC, receiving_account_code, receiving_ACC);

        //update storage to complete asset reception. handling info changed during shipment

        return true;
    }

    function transfer_asset(string memory serial_number, string memory from_acc, string memory to_acc)
    public returns (bool success) {
        if (keccak256(abi.encodePacked((from_acc))) == keccak256(abi.encodePacked((assetStruct[serial_number].ACC)))) {
            assetStruct[serial_number].ACC = to_acc;
            emit asset_transferred(serial_number, from_acc, to_acc);
            return true;
        }
       emit asset_transfer_failed(serial_number, from_acc, to_acc);
       return false;
    }

    //NEEDS 200K GAS
    function delete_asset(string memory serial_number)
    public returns(bool success) {
        assetCountByUIC[assetStruct[serial_number].UIC] -= 1;
        assetCountByACC[assetStruct[serial_number].ACC] -= 1;
        delete assetStruct[serial_number];
        
        //decrement total counter
        assetCountTotal -= 1;

        emit asset_deleted(serial_number, assetCountTotal, assetStruct[serial_number].UIC, assetCountByUIC[assetStruct[serial_number].UIC], assetStruct[serial_number].ACC, assetCountByACC[assetStruct[serial_number].ACC]);
        return true;
    }

    function update_condition_code (string memory serial_number, condition_code new_asset_code)
    public returns (bool success) {
      assetStruct[serial_number].code = new_asset_code;
      emit asset_condition_code_updated(serial_number, new_asset_code);
      return true;
    }

    function get_asset_info(string memory serial_number)
    public view returns (string memory ACC,
    string memory account_code, condition_code code, string memory UIC, string memory stock_number,
    string memory NSN) {
        return (
                assetStruct[serial_number].ACC,
                assetStruct[serial_number].account_code,
                assetStruct[serial_number].code,
                assetStruct[serial_number].UIC,
                assetStruct[serial_number].stock_number,
                assetStruct[serial_number].NSN);
    }

    function get_asset_shipping_info (string memory serial_number)
    public view returns (string memory lot_number, uint IUIDtag,
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

    function get_asset_RDD(string memory serial_number)
    public view returns (string memory RDD){
        return (assetStruct[serial_number].RDD);
    }

    function get_asset_transit_status(string memory serial_number)
    public view returns(bool transit_status) {
        return (assetStruct[serial_number].in_transit);
    }

    function concatenate_string(string memory a, string memory b)
    public pure returns (string memory concat_str) {
        return string(abi.encodePacked(a,":", b));
    }
    
    function getTotal() public view returns (int){
        return assetCountTotal;
    }
}
