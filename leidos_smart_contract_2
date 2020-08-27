pragma solidity ^0.5.12;

contract asset_management {
    enum condition_code {OK, DAMAGED, EXPENDED, DESTROYED, LOST, UNKNOWN}

    //asset lifecycle events
    //create/update_handling/update_storage/ship/update_gps/receive/transfer/update_storage/delete - update_condition
    event asset_created(string serial_number, uint asset_IUIDtag, string asset_NSN, condition_code asset_condition_code, uint asset_created_count, uint asset_count_total, uint assets_in_storage, uint assets_in_transit, uint asset_deleted_count);
    event asset_handling_update(string serial_number, string curr_UIC, string curr_RIC, string curr_account_code);
    event asset_storage_update(string serial_number, string curr_ACC, string curr_lot_number, string curr_stock_number);
    event asset_shipped(string serial_number, string from_UIC, string to_UIC, string new_RDD, uint assets_in_storage, uint assets_in_transit);
    event asset_transit_update(string serial_number, bool asset_in_transit);
    event asset_gps_shipment_coordinates_update(string serial_number, string gps_coordinates);
    event asset_received(string serial_number, string receiving_UIC, string receiving_RIC, string receiving_account_code, string receiving_ACC, uint assets_in_transit, uint assets_in_storage);
    event asset_transferred(string serial_number, string from_acc, string to_acc);
    event asset_condition_code_updated(string serial_number, condition_code asset_condition_code);
    event asset_deleted(string serial_number, uint asset_created_count, uint asset_count_total, uint asset_deleted_count, uint assets_in_transit, uint assets_in_storage);

    // asset exception error events
    event failed_asset_existence(string serial_number, string message);
    event failed_asset_update(string serial_number,  uint asset_IUIDtag, string message);

    // violation events
    event temperature_violation(string serial_number, uint asset_IUIDtag, int value, uint time);
    event humidity_violation(string serial_number, uint asset_IUIDtag, int value, uint time);
    event geo_violation(string serial_number, uint asset_IUIDtag, string latitude, int latitude_value, string longitude, int longitude_value, uint time);
    
    struct asset_attr {

        //variable to check for the existence of a given asset mapping
        bool exists;
        
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

    struct VT_Pair{

        // value
        int value;
        
        // epoch time
        uint time;
    }

    struct Geo_Pair{
        
        // latitude information: n for north s for south
        string latitude;
        int latitude_value;
        
        // longitude information: w for west e for east
        string longitude;
        int longitude_value;
        
        uint time;
    }
    
    struct Record{
        
        // Sizes of various violations
        uint humidity_violation_size;
        uint temp_violation_size;
        uint geo_violation_size;
        
        // Violation pair arrays
        VT_Pair[] humidity;
        VT_Pair[] temp;
        Geo_Pair[] geo;
    }

    uint assetCountTotal;
    uint assetsInTransit;
    uint assetsInStorage;
    uint assetsCreatedCount;
    uint assetDeletedCount;
    mapping(string=>asset_attr) assetStruct;
    mapping(string => Record) violations;
 
    constructor() public {
       assetCountTotal = 0;
       assetsInTransit = 0;
       assetsInStorage = 0;
       assetsCreatedCount = 0;
       assetDeletedCount = 0;
    }

    function create_new_asset(string memory serial_number, uint asset_IUIDtag, string memory asset_NSN, condition_code asset_condition_code)
    public returns (bool success) {

        //if asset with serial number already exists, emit failure event
        if (assetStruct[serial_number].exists == true) {
            emit failed_asset_existence(serial_number, "create_new_asset Failed: Asset already exists.");
            return false;
        }
        //asset cannot be created with EXPENDED or DESTROYED condition code, emit failure event
        else if (asset_condition_code == condition_code.EXPENDED || asset_condition_code == condition_code.DESTROYED) {
            emit failed_asset_update(serial_number, asset_IUIDtag, "create_new_asset Failed: Cannot create Asset with condition (2 - EXPENDED) or (3 - DESTROYED).");
            return false;
        }
        //create asset, emit success event
        else {
            assetStruct[serial_number].exists = true;
            assetStruct[serial_number].IUIDtag = asset_IUIDtag;
            assetStruct[serial_number].NSN = asset_NSN;
            assetStruct[serial_number].code = asset_condition_code;

            //increment created and total counter
            assetsCreatedCount += 1;
            assetCountTotal += 1;

            //emit created asset
            emit asset_created(serial_number, asset_IUIDtag, asset_NSN, asset_condition_code, assetsCreatedCount, assetCountTotal, assetsInStorage, assetsInTransit, assetDeletedCount);
            return true;
            //to complete asset create, update handling and storage
        }
    }

    function update_asset_in_transit_field(string memory serial_number, bool asset_in_transit)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "update_asset_in_transit_field") == false) {
            return false;
        }
        //if asset_in_transit is equal to asset's current transit state, emit failure event
        else if (assetStruct[serial_number].in_transit == asset_in_transit) {
            emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "update_asset_in_transit_field Failed: Attempt to modify transit field with same value.");
            return false;
        }
        // update asset in transit field, emit success event
        else {
            assetStruct[serial_number].in_transit = asset_in_transit;
            emit asset_transit_update(serial_number, asset_in_transit);
            return true;
        }
    }

    function update_asset_handling(string memory serial_number, string memory curr_UIC, string memory curr_RIC, string memory curr_account_code)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "update_asset_handling") == false) {
            return false;
        }
        // update handling info of asset, emit success event
        else {
            assetStruct[serial_number].UIC = curr_UIC;
            assetStruct[serial_number].RIC = curr_RIC;
            assetStruct[serial_number].account_code = curr_account_code;

            emit asset_handling_update(serial_number, curr_UIC, curr_RIC, curr_account_code);
            return true;
        }
    }

    function update_asset_storage(string memory serial_number, string memory curr_ACC, string memory curr_lot_number, string memory curr_stock_number)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "update_asset_storage") == false) {
            return false;
        }
        // update storage info of asset, emit success event
        else {
            assetStruct[serial_number].ACC = curr_ACC;
            assetStruct[serial_number].lot_number = curr_lot_number;
            assetStruct[serial_number].stock_number = curr_stock_number;

            emit asset_storage_update(serial_number, curr_ACC, curr_lot_number, curr_stock_number);
            return true;
        }
    }
    
    function ship_asset(string memory serial_number, string memory from_UIC, string memory to_UIC, string memory to_RIC, string memory to_account_code, string memory transportation_code, string memory transportation_contract_number, string memory RDD)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "ship_asset") == false) {
            return false;
        }
        // ship asset, emit success event
        else {

            //update transit
            if (update_asset_in_transit_field(serial_number, true) == false) {
                emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "ship_asset Failed: See update_asset_in_transit_field error.");
                return false;
            }

            //clear storage info
            if (update_asset_storage(serial_number,assetStruct[serial_number].ACC,"","") == false) {
                emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "ship_asset Failed: See update_asset_storage error.");
                return false;
            }

            //update handling info
            if (update_asset_handling(serial_number, to_UIC, to_RIC, to_account_code) == false) {
                emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "ship_asset Failed: See update_asset_handling error.");
                return false;
            }

            assetStruct[serial_number].transportation_code = transportation_code;
            assetStruct[serial_number].transportation_contract_number = transportation_contract_number;
            assetStruct[serial_number].RDD = RDD;

            emit asset_shipped(serial_number, from_UIC, to_UIC, RDD, assetsInStorage, assetsInTransit);

            //increment assets in transit
            assetsInTransit += 1;

            //decrement assets in storage
            if(assetsInStorage > 0){
                assetsInStorage -= 1;
            }

            return true;
        }
    }

    function update_asset_gps_shipment_coordinates(string memory serial_number, string memory gps_coordinates)
    public returns (bool success) {
        
        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "update_asset_gps_shipment_coordinates") == false) {
            return false;
        }
        //asset must be in transit to update shipment coordinates
        else if (assetStruct[serial_number].in_transit == false) {
            emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "update_asset_gps_shipment_coordinates Failed: Asset not in transit.");
            return false;
        }
        // update asset gps shipmet coordinates, emit success event
        else {
            assetStruct[serial_number].GPS_shipment_coordinates = gps_coordinates;
            emit asset_gps_shipment_coordinates_update(serial_number, gps_coordinates);
            return true;
        }
    }

    function receive_asset(string memory serial_number, string memory receiving_UIC, string memory receiving_RIC, string memory receiving_account_code, string memory receiving_ACC)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "receive_asset") == false) {
            return false;
        }
        // receive shipment, emit success event
        else {
            //update ACC
            if (transfer_asset(serial_number, assetStruct[serial_number].ACC, receiving_ACC) == false) {
                emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "receive_asset Failed: See transfer_asset error.");
                return false;
            }

            //update transit
            if (update_asset_in_transit_field(serial_number, false) == false) {
                emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "receive_asset Failed: See update_asset_in_transit_field error.");
                return false;
            }

            //clear RDD
            assetStruct[serial_number].RDD = "";

            //increment storage
            assetsInStorage += 1;

            //decrement assets in transit
            if(assetsInTransit > 0){
                assetsInTransit -= 1;
            }

            emit asset_received(serial_number, receiving_UIC, receiving_RIC, receiving_account_code, receiving_ACC, assetsInTransit, assetsInStorage);
            return true;
            //update storage to complete asset reception. handling info changed during shipment
        }
    }

    function transfer_asset(string memory serial_number, string memory from_acc, string memory to_acc)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "transfer_asset") == false) {
            return false;
        }
        // from_acc and asset acc must be the same
        else if (stringCompare(from_acc, assetStruct[serial_number].ACC) == false) {
            emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "transfer_asset Failed: Transferring ACC must be the same as the Asset owner ACC.");
            return false;
        }
        // transfer asset, emit success event
        else {
            assetStruct[serial_number].ACC = to_acc;
            emit asset_transferred(serial_number, from_acc, to_acc);
            return true;
        }
    }

    function delete_asset(string memory serial_number)
    public returns(bool success) {
        
        //if asset with serial number does not exist, emit failure event
        if (assetStruct[serial_number].exists == false) {
            emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, "delete_asset Failed: Asset does not exist with serial number.");
            return false;
        }
        //delete asset, emit success event
        else {
            delete assetStruct[serial_number];

            //increment deleted counter
            assetDeletedCount += 1;

            //decrement current total counter
            assetCountTotal -= 1;

            //decrement from storage
            if(assetsInStorage > 0){
                assetsInStorage -= 1;
            }

            emit asset_deleted(serial_number, assetsCreatedCount, assetCountTotal, assetDeletedCount, assetsInTransit, assetsInStorage);
            return true;
        }
    }

    function update_condition_code (string memory serial_number, condition_code new_condition_code)
    public returns (bool success) {

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "update_condition_code") == false) {
            return false;
        }
        // update code, emit success event
        else {
            assetStruct[serial_number].code = new_condition_code;
            emit asset_condition_code_updated(serial_number, new_condition_code);
            return true;
        }
    }

    function addHumidityViolation(string memory serial_number, int value, uint time)
    public returns (bool){

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "addHumidityViolation") == false) {
            return false;
        }
        // update code, emit violation event
        else {
            violations[serial_number].humidity.push(VT_Pair(value, time));
            violations[serial_number].humidity_violation_size++;
            emit humidity_violation(serial_number, assetStruct[serial_number].IUIDtag, value, time);
            return true;
        }
    }
    
    function addTempViolation(string memory serial_number, int value, uint time)
    public returns (bool){

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "addTempViolation") == false) {
            return false;
        }
        // update code, emit violation event
        else {
            violations[serial_number].temp.push(VT_Pair(value, time));
            violations[serial_number].temp_violation_size++;
            emit temperature_violation(serial_number, assetStruct[serial_number].IUIDtag, value, time);
            return true;
        }
    }
    
    function addGeoViolation(string memory serial_number, string memory latitude, int latitude_value, string memory longitude, int longitude_value, uint time)
    public returns (bool){

        //if asset with serial number does not exist or condition code is EXPENDED/DESTROYED emit failure event
        if (validate_serial_number_and_condition(serial_number, "addGeoViolation") == false) {
            return false;
        }
        // update code, emit violation event
        else {
            violations[serial_number].geo.push(Geo_Pair(latitude, latitude_value, longitude, longitude_value, time));
            violations[serial_number].geo_violation_size++;
            emit geo_violation(serial_number, assetStruct[serial_number].IUIDtag, latitude, latitude_value, longitude, longitude_value, time);
            return true;
        }
    }
    
    function getHumidityViolationSize(string memory serial_number)
    public view returns (uint){
        return violations[serial_number].humidity_violation_size;
    }
    
    function getTempViolationSize(string memory serial_number)
    public view returns (uint){
        return violations[serial_number].temp_violation_size;
    }
    
    function getGeoViolationSize(string memory serial_number)
    public view returns (uint){
        return violations[serial_number].geo_violation_size;
    }
    
    function getHumidityViolationRecord(string memory serial_number, uint index)
    public view returns (int, uint){
        return (violations[serial_number].humidity[index].value, violations[serial_number].humidity[index].time);
    }
    
    function getTempViolationRecord(string memory serial_number, uint index)
    public view returns (int, uint){
        return (violations[serial_number].temp[index].value, violations[serial_number].temp[index].time);
    }
    
    function getGeoViolationRecord(string memory serial_number, uint index)
    public view returns (string memory, int, string memory, int, uint){
        return (violations[serial_number].geo[index].latitude, 
        violations[serial_number].geo[index].latitude_value,
        violations[serial_number].geo[index].longitude, 
        violations[serial_number].geo[index].longitude_value,
        violations[serial_number].geo[index].time);
    }

    function validate_serial_number_and_condition(string memory serial_number, string memory caller)
    private returns (bool success) {
        //if asset with serial number does not exist, emit failure event
        if (assetStruct[serial_number].exists == false) {
            emit failed_asset_existence(serial_number, string(abi.encodePacked(caller, " Failed: Asset does not exist.")));
            return false;
        }
        //assets with EXPENDED or DESTROYED condition code handling cannot be updated, emit failure event
        else if (assetStruct[serial_number].code == condition_code.EXPENDED || assetStruct[serial_number].code == condition_code.DESTROYED) {
            emit failed_asset_update(serial_number, assetStruct[serial_number].IUIDtag, string(abi.encodePacked(caller, " Failed: Asset with condition (2 - EXPENDED) or (3 - DESTROYED).")));
            return false;
        }
        else {
            return true;
        }
    }

    function stringCompare(string memory a, string memory b)
    private pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
        }
    }
}
