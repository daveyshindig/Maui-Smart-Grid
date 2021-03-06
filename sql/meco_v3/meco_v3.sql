--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: meco_v3; Type: COMMENT; Schema: -; Owner: sepgroup
--

COMMENT ON DATABASE meco_v3 IS 'This is version 3 of the MECO database that is being developed for adding the event data to the database.';


--
-- Name: az; Type: SCHEMA; Schema: -; Owner: ashkan
--

CREATE SCHEMA az;


ALTER SCHEMA az OWNER TO ashkan;

--
-- Name: cd; Type: SCHEMA; Schema: -; Owner: christian
--

CREATE SCHEMA cd;


ALTER SCHEMA cd OWNER TO christian;

--
-- Name: dw; Type: SCHEMA; Schema: -; Owner: dave
--

CREATE SCHEMA dw;


ALTER SCHEMA dw OWNER TO dave;

--
-- Name: dz; Type: SCHEMA; Schema: -; Owner: daniel
--

CREATE SCHEMA dz;


ALTER SCHEMA dz OWNER TO daniel;

--
-- Name: SCHEMA dz; Type: COMMENT; Schema: -; Owner: daniel
--

COMMENT ON SCHEMA dz IS 'Schema for Daniel Zhang.';


--
-- Name: ep; Type: SCHEMA; Schema: -; Owner: eileen
--

CREATE SCHEMA ep;


ALTER SCHEMA ep OWNER TO eileen;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: zero_to_null(real); Type: FUNCTION; Schema: public; Owner: daniel
--

CREATE FUNCTION zero_to_null(real) RETURNS real
    LANGUAGE sql
    AS $_$select case when $1 < 1e-3 then null else $1 end;$_$;


ALTER FUNCTION public.zero_to_null(real) OWNER TO daniel;

--
-- Name: FUNCTION zero_to_null(real); Type: COMMENT; Schema: public; Owner: daniel
--

COMMENT ON FUNCTION zero_to_null(real) IS 'Change float4 value to null if it is less than 1e-3. @author Daniel Zhang (張道博)';


--
-- Name: zero_to_null(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION zero_to_null(double precision) RETURNS double precision
    LANGUAGE sql
    AS $_$select case when $1 < 1e-3 then null else $1 end;$_$;


ALTER FUNCTION public.zero_to_null(double precision) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Event; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "Event" (
    event_name character varying,
    event_time timestamp without time zone,
    event_text character varying,
    event_data_id bigint,
    event_id bigint NOT NULL
);


ALTER TABLE public."Event" OWNER TO sepgroup;

--
-- Name: EventData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "EventData" (
    end_time timestamp without time zone,
    number_events smallint,
    start_time timestamp without time zone,
    meter_data_id bigint,
    event_data_id bigint NOT NULL
);


ALTER TABLE public."EventData" OWNER TO sepgroup;

--
-- Name: MeterData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "MeterData" (
    meter_data_id bigint NOT NULL,
    mac_id character(23) NOT NULL,
    meter_name character(8) NOT NULL,
    util_device_id character(8) NOT NULL,
    created timestamp without time zone
);


ALTER TABLE public."MeterData" OWNER TO sepgroup;

--
-- Name: TABLE "MeterData"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "MeterData" IS 'Root table for MECO energy data. This table is set to cascade delete so that deletions here are propagated through the MECO energy data branches. --Daniel Zhang (張道博)';


--
-- Name: COLUMN "MeterData".created; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON COLUMN "MeterData".created IS 'timestamp for when data is inserted';


SET search_path = dz, pg_catalog;

--
-- Name: count_of_event_duplicates; Type: VIEW; Schema: dz; Owner: daniel
--

CREATE VIEW count_of_event_duplicates AS
    SELECT "Event".event_time, "MeterData".meter_data_id, "EventData".event_data_id, (count(*) - 1) AS "Duplicate Count" FROM ((public."MeterData" JOIN public."EventData" ON (("MeterData".meter_data_id = "EventData".meter_data_id))) JOIN public."Event" ON (("EventData".event_data_id = "Event".event_data_id))) GROUP BY "Event".event_time, "MeterData".meter_data_id, "EventData".event_data_id HAVING ((count(*) - 1) > 0) ORDER BY "Event".event_time;


ALTER TABLE dz.count_of_event_duplicates OWNER TO daniel;

SET search_path = public, pg_catalog;

--
-- Name: Interval; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "Interval" (
    interval_read_data_id bigint NOT NULL,
    interval_id bigint NOT NULL,
    block_sequence_number smallint NOT NULL,
    end_time timestamp without time zone NOT NULL,
    gateway_collected_time timestamp without time zone NOT NULL,
    interval_sequence_number smallint NOT NULL
);


ALTER TABLE public."Interval" OWNER TO sepgroup;

--
-- Name: TABLE "Interval"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "Interval" IS 'Part of the Reading branch for MECO energy data. --Daniel Zhang (張道博)';


--
-- Name: IntervalReadData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "IntervalReadData" (
    interval_read_data_id bigint NOT NULL,
    meter_data_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    interval_length smallint NOT NULL,
    number_intervals integer NOT NULL
);


ALTER TABLE public."IntervalReadData" OWNER TO sepgroup;

--
-- Name: TABLE "IntervalReadData"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "IntervalReadData" IS 'Part of the Reading branch for MECO energy data. --Daniel Zhang (張道博)';


--
-- Name: MeterLocationHistory; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "MeterLocationHistory" (
    meter_name character varying NOT NULL,
    mac_address character varying,
    installed timestamp(6) without time zone NOT NULL,
    uninstalled timestamp(6) without time zone,
    location character varying,
    address character varying,
    city character varying,
    latitude double precision,
    longitude double precision,
    old_service_point_id character varying,
    service_point_height double precision,
    service_point_latitude double precision,
    service_point_longitude double precision,
    notes character varying,
    service_point_id character varying
);


ALTER TABLE public."MeterLocationHistory" OWNER TO sepgroup;

--
-- Name: TABLE "MeterLocationHistory"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "MeterLocationHistory" IS 'Links meters to service points and provides a history of meter installations and uninstallations. --Daniel Zhang (張道博)';


--
-- Name: Reading; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "Reading" (
    interval_id bigint NOT NULL,
    reading_id bigint NOT NULL,
    block_end_value real,
    channel smallint NOT NULL,
    raw_value smallint NOT NULL,
    uom character varying,
    value real
);


ALTER TABLE public."Reading" OWNER TO sepgroup;

--
-- Name: TABLE "Reading"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "Reading" IS 'Part of the Reading branch for MECO energy data. --Daniel Zhang (張道博)';


SET search_path = dz, pg_catalog;

--
-- Name: readings_by_meter_location_history; Type: VIEW; Schema: dz; Owner: daniel
--

CREATE VIEW readings_by_meter_location_history AS
    SELECT "MeterLocationHistory".meter_name, "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".location, "MeterLocationHistory".address, "MeterLocationHistory".latitude, "MeterLocationHistory".longitude, "MeterLocationHistory".installed, "MeterLocationHistory".uninstalled, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "Interval".end_time, "MeterData".meter_data_id FROM ((((public."MeterLocationHistory" JOIN public."MeterData" ON ((("MeterLocationHistory".meter_name)::bpchar = "MeterData".meter_name))) JOIN public."IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN public."Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN public."Reading" ON (((("Interval".interval_id = "Reading".interval_id) AND ("Interval".end_time >= "MeterLocationHistory".installed)) AND CASE WHEN ("MeterLocationHistory".uninstalled IS NULL) THEN true ELSE ("Interval".end_time < "MeterLocationHistory".uninstalled) END)));


ALTER TABLE dz.readings_by_meter_location_history OWNER TO daniel;

--
-- Name: deprecated_readings_by_mlh_transposed_columns_opt1; Type: VIEW; Schema: dz; Owner: daniel
--

CREATE VIEW deprecated_readings_by_mlh_transposed_columns_opt1 AS
    SELECT readings_by_meter_location_history.service_point_id, max(CASE WHEN (readings_by_meter_location_history.channel = (1)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Energy to House kwH", max(CASE WHEN (readings_by_meter_location_history.channel = (2)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Energy from House kwH(rec)", max(CASE WHEN (readings_by_meter_location_history.channel = (3)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Net Energy to House KwH", max(CASE WHEN (readings_by_meter_location_history.channel = (4)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "voltage at house", max(readings_by_meter_location_history.service_point_latitude) AS service_point_latitude, max(readings_by_meter_location_history.service_point_longitude) AS service_point_longitude, max((readings_by_meter_location_history.location)::text) AS "location_ID", max((readings_by_meter_location_history.address)::text) AS address, max(readings_by_meter_location_history.latitude) AS location_latitude, max(readings_by_meter_location_history.longitude) AS location_longitude, max(readings_by_meter_location_history.end_time) AS end_time FROM readings_by_meter_location_history GROUP BY readings_by_meter_location_history.service_point_id;


ALTER TABLE dz.deprecated_readings_by_mlh_transposed_columns_opt1 OWNER TO daniel;

--
-- Name: VIEW deprecated_readings_by_mlh_transposed_columns_opt1; Type: COMMENT; Schema: dz; Owner: daniel
--

COMMENT ON VIEW deprecated_readings_by_mlh_transposed_columns_opt1 IS 'NEEDS GROUP BY END TIME. Invalid optimization 1 for readings by MLH. Channels are transposed to columns. End time sorting is removed.';


--
-- Name: readings_by_mlh_new_spid_for_ashkan_from_2013-07-01; Type: VIEW; Schema: dz; Owner: daniel
--

CREATE VIEW "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" AS
    SELECT readings_by_meter_location_history.service_point_id, max(CASE WHEN (readings_by_meter_location_history.channel = (1)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Energy to House kwH", max(CASE WHEN (readings_by_meter_location_history.channel = (2)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Energy from House kwH(rec)", max(CASE WHEN (readings_by_meter_location_history.channel = (3)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "Net Energy to House KwH", max(CASE WHEN (readings_by_meter_location_history.channel = (4)::smallint) THEN readings_by_meter_location_history.value ELSE NULL::real END) AS "voltage at house", max((readings_by_meter_location_history.address)::text) AS address, readings_by_meter_location_history.end_time FROM readings_by_meter_location_history WHERE ((readings_by_meter_location_history.end_time >= '2013-07-01 00:00:00'::timestamp without time zone) AND (readings_by_meter_location_history.end_time <= '2014-02-01 00:00:00'::timestamp without time zone)) GROUP BY readings_by_meter_location_history.service_point_id, readings_by_meter_location_history.end_time;


ALTER TABLE dz."readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" OWNER TO daniel;

--
-- Name: readings_unfiltered; Type: VIEW; Schema: dz; Owner: daniel
--

CREATE VIEW readings_unfiltered AS
    SELECT "Interval".end_time, "MeterData".meter_name, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "IntervalReadData".start_time, "IntervalReadData".end_time AS ird_end_time, "MeterData".meter_data_id, "Reading".interval_id FROM (((public."MeterData" JOIN public."IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN public."Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN public."Reading" ON (("Interval".interval_id = "Reading".interval_id)));


ALTER TABLE dz.readings_unfiltered OWNER TO daniel;

SET search_path = public, pg_catalog;

--
-- Name: AsBuilt; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "AsBuilt" (
    owner character(100),
    address character(200),
    spid integer NOT NULL,
    ihd character(125),
    pct character(125),
    load_control character(125),
    repeater character(125)
);


ALTER TABLE public."AsBuilt" OWNER TO sepgroup;

--
-- Name: AverageFifteenMinIrradianceData; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "AverageFifteenMinIrradianceData" (
    sensor_id integer NOT NULL,
    irradiance_w_per_m2 double precision,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public."AverageFifteenMinIrradianceData" OWNER TO postgres;

--
-- Name: TABLE "AverageFifteenMinIrradianceData"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "AverageFifteenMinIrradianceData" IS 'Static table generated by aggregate-irradiance-data.sh. --Daniel Zhang (張道博)';


--
-- Name: AverageFifteenMinKiheiSCADATemperatureHumidity; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" (
    "timestamp" timestamp without time zone NOT NULL,
    met_air_temp_degf double precision,
    met_rel_humid_pct double precision
);


ALTER TABLE public."AverageFifteenMinKiheiSCADATemperatureHumidity" OWNER TO postgres;

--
-- Name: BatteryWailea; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "BatteryWailea" (
    datetime timestamp without time zone,
    kvar double precision,
    kw double precision,
    soc double precision,
    pwr_ref_volt double precision
);


ALTER TABLE public."BatteryWailea" OWNER TO sepgroup;

--
-- Name: TABLE "BatteryWailea"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "BatteryWailea" IS 'KVAR – This is the var output of the battery system (- is absorbing vars, + is discharging vars)
KW – This is the kilowatt output of the battery system (- is absorbing kW, + is discharging kW)
SOC – This is the state of charge for the battery system (100% is full charged, 0% is fully discharged)
PWR_REF/VOLT – This is the measurement of voltage (volts) at the protection relay for circuit breaker 1517.';


--
-- Name: CircuitData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "CircuitData" (
    circuit integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    amp_a integer,
    amp_b integer,
    amp_c integer,
    mvar double precision,
    mw double precision,
    upload_date date DEFAULT now()
);


ALTER TABLE public."CircuitData" OWNER TO sepgroup;

--
-- Name: CircuitDataCopy; Type: TABLE; Schema: public; Owner: dave; Tablespace: 
--

CREATE TABLE "CircuitDataCopy" (
    circuit integer,
    "timestamp" timestamp without time zone,
    amp_a integer,
    amp_b integer,
    amp_c integer,
    mvar double precision,
    mw double precision,
    upload_date date
);


ALTER TABLE public."CircuitDataCopy" OWNER TO dave;

--
-- Name: EgaugeEnergyAutoload; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "EgaugeEnergyAutoload" (
    egauge_id integer NOT NULL,
    datetime timestamp(6) without time zone NOT NULL,
    use_kw double precision,
    gen_kw double precision,
    grid_kw double precision,
    ac_kw double precision,
    acplus_kw double precision,
    clotheswasher_kw double precision,
    clotheswasher_usage_kw double precision,
    dhw_kw double precision,
    dishwasher_kw double precision,
    dryer_kw double precision,
    dryer_usage_kw double precision,
    fan_kw double precision,
    garage_ac_kw double precision,
    garage_ac_usage_kw double precision,
    large_ac_kw double precision,
    large_ac_usage_kw double precision,
    microwave_kw double precision,
    oven_kw double precision,
    oven_usage_kw double precision,
    range_kw double precision,
    range_usage_kw double precision,
    refrigerator_kw double precision,
    refrigerator_usage_kw double precision,
    rest_of_house_usage_kw double precision,
    solarpump_kw double precision,
    stove_kw double precision,
    upload_date timestamp(6) without time zone,
    oven_and_microwave_kw double precision,
    oven_and_microwave_plus_kw double precision,
    house_kw double precision,
    shop_kw double precision,
    addition_kw double precision,
    dhw_load_control double precision
);


ALTER TABLE public."EgaugeEnergyAutoload" OWNER TO sepgroup;

--
-- Name: TABLE "EgaugeEnergyAutoload"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "EgaugeEnergyAutoload" IS 'Data that is autoloaded by the MSG eGauge Service. @author Daniel Zhang (張道博)';


--
-- Name: EgaugeInfo; Type: TABLE; Schema: public; Owner: eileen; Tablespace: 
--

CREATE TABLE "EgaugeInfo" (
    svc_pt_id character varying,
    address character varying,
    egauge character varying,
    egauge_id integer
);


ALTER TABLE public."EgaugeInfo" OWNER TO eileen;

--
-- Name: IrradianceData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "IrradianceData" (
    sensor_id integer NOT NULL,
    irradiance_w_per_m2 double precision,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public."IrradianceData" OWNER TO sepgroup;

--
-- Name: IrradianceSensorInfo; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "IrradianceSensorInfo" (
    sensor_id integer NOT NULL,
    latitude double precision,
    longitude double precision,
    manufacturer character varying,
    model character varying,
    name character varying
);


ALTER TABLE public."IrradianceSensorInfo" OWNER TO sepgroup;

--
-- Name: KiheiSCADATemperatureHumidity; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "KiheiSCADATemperatureHumidity" (
    "timestamp" timestamp without time zone NOT NULL,
    met_air_temp_degf double precision,
    met_rel_humid_pct double precision
);


ALTER TABLE public."KiheiSCADATemperatureHumidity" OWNER TO postgres;

--
-- Name: LocationRecords; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "LocationRecords" (
    load_device_type character varying,
    load_action character varying,
    device_util_id character varying NOT NULL,
    device_serial_no character varying,
    device_status character varying,
    device_operational_status character varying,
    install_date timestamp without time zone,
    remove_date timestamp without time zone,
    cust_account_no character varying,
    cust_name character varying,
    service_point_util_id character varying,
    service_type character varying,
    meter_phase character varying,
    cust_billing_cycle character varying,
    location_code character varying,
    voltage_level character varying,
    voltage_phase character varying,
    service_pt_height character varying,
    service_pt_longitude real,
    service_pt_latitude real,
    device_pt_ratio character varying,
    device_ct_ratio character varying,
    premise_util_id character varying,
    premise_type character varying,
    premise_description character varying,
    address1 character varying,
    address2 character varying,
    city character varying,
    cross_street character varying,
    state character(2),
    post_code character varying,
    country character varying,
    timezone character varying,
    region_code character varying,
    map_page_no character varying,
    map_coord character varying,
    longitude real,
    latitude real
);


ALTER TABLE public."LocationRecords" OWNER TO sepgroup;

--
-- Name: MSG_PV_Data; Type: TABLE; Schema: public; Owner: eileen; Tablespace: 
--

CREATE TABLE "MSG_PV_Data" (
    util_device_id character varying(64) NOT NULL,
    map integer,
    no integer,
    pv_mod_size_kw double precision,
    inverter_model character varying(40),
    inverter_size_kw real,
    system_cap_kw real,
    add_cap_kw real,
    upg_date real,
    battery character varying(10),
    substation character varying(20),
    circuit real,
    upload_date timestamp without time zone
);


ALTER TABLE public."MSG_PV_Data" OWNER TO eileen;

--
-- Name: COLUMN "MSG_PV_Data".util_device_id; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".util_device_id IS 'meter id number';


--
-- Name: COLUMN "MSG_PV_Data".map; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".map IS 'referencing map from Mel Gehrs';


--
-- Name: COLUMN "MSG_PV_Data".no; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".no IS 'net energy metering number from MECO';


--
-- Name: COLUMN "MSG_PV_Data".pv_mod_size_kw; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".pv_mod_size_kw IS 'total capacity of all the modules (panels)';


--
-- Name: COLUMN "MSG_PV_Data".inverter_model; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".inverter_model IS 'Inverter make and model number';


--
-- Name: COLUMN "MSG_PV_Data".inverter_size_kw; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".inverter_size_kw IS 'total inverter capacity';


--
-- Name: COLUMN "MSG_PV_Data".system_cap_kw; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".system_cap_kw IS 'System capacity: smaller of the two - either module size or inverter size';


--
-- Name: COLUMN "MSG_PV_Data".add_cap_kw; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".add_cap_kw IS 'can extra capacity be added? Installation with microinverters can easily add capacity';


--
-- Name: COLUMN "MSG_PV_Data".upg_date; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".upg_date IS 'last date of an upgrade of system capacity';


--
-- Name: COLUMN "MSG_PV_Data".battery; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".battery IS 'if there is a battery (none in Maui Meadows in 2013)';


--
-- Name: COLUMN "MSG_PV_Data".substation; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".substation IS 'substation ID';


--
-- Name: COLUMN "MSG_PV_Data".circuit; Type: COMMENT; Schema: public; Owner: eileen
--

COMMENT ON COLUMN "MSG_PV_Data".circuit IS 'circuit ID number';


--
-- Name: MeterRecords; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "MeterRecords" (
    type character varying,
    action character varying,
    did_sub_type character varying,
    device_util_id character varying NOT NULL,
    device_serial_no character varying,
    device_status character varying,
    device_operational_status character varying,
    device_name character varying,
    device_description character varying,
    device_mfg character varying,
    device_mfg_date timestamp(6) without time zone,
    device_mfg_model character varying,
    device_sw_ver_no character varying,
    device_sw_rev_no character varying,
    device_sw_patch_no character varying,
    device_sw_config character varying,
    device_hw_ver_no character varying,
    device_hw_rev_no character varying,
    device_hw_patch_no character varying,
    device_hw_config character varying,
    meter_form_type character varying,
    meter_base_type character varying,
    max_amp_class character varying,
    rollover_point character varying,
    volt_type character varying,
    nic_mac_address character varying,
    nic_serial_no character varying,
    nic_rf_channel character varying,
    nic_network_identifier character varying,
    nic_model character varying,
    nic_sw_ver_no character varying,
    nic_sw_rev_no character varying,
    nic_sw_patch_no character varying,
    nic_released_date character varying,
    nic_sw_config character varying,
    nic_hw_ver_no character varying,
    nic_hw_rev_no character varying,
    nic_hw_patch_no character varying,
    nic_hw_config character varying,
    master_password character varying,
    reader_password character varying,
    cust_password character varying,
    meter_mode character varying,
    timezone_region character varying,
    battery_mfg_name character varying,
    battery_model_no character varying,
    battery_serial_no character varying,
    battery_mfg_date character varying,
    battery_exp_date character varying,
    battery_installed_date character varying,
    battery_lot_no character varying,
    battery_last_tested_date character varying,
    price_program character varying,
    catalog_number character varying,
    program_seal character varying,
    meter_program_id character varying,
    device_attribute_1 character varying,
    device_attribute_2 character varying,
    device_attribute_3 character varying,
    device_attribute_4 character varying,
    device_attribute_5 character varying,
    nic_attribute_1 character varying,
    nic_attribute_2 character varying,
    nic_attribute_3 character varying,
    nic_attribute_4 character varying,
    nic_attribute_5 character varying
);


ALTER TABLE public."MeterRecords" OWNER TO sepgroup;

--
-- Name: NotificationHistory; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "NotificationHistory" (
    "notificationType" character varying NOT NULL,
    "notificationTime" timestamp without time zone NOT NULL
);


ALTER TABLE public."NotificationHistory" OWNER TO postgres;

--
-- Name: TABLE "NotificationHistory"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "NotificationHistory" IS 'Used for tracking automatic notifications. @author Daniel Zhang (張道博)';


--
-- Name: PVServicePointIDs; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "PVServicePointIDs" (
    old_pv_service_point_id character varying,
    old_house_service_point_id character varying,
    "PV_Mod_size_kW" double precision,
    inverter_model character varying,
    "size_kW" real,
    "system_cap_kW" real,
    bat character varying,
    sub character varying,
    circuit smallint,
    date_uploaded timestamp without time zone DEFAULT '2014-01-19 19:53:55.497375'::timestamp without time zone,
    has_meter smallint,
    has_separate_pv_meter smallint,
    "add_cap_kW" real,
    upgraded_total_kw real,
    street character varying,
    city character varying,
    state character varying,
    zip integer,
    month_installed integer,
    year_installed integer,
    notes character varying,
    pv_service_point_id character varying,
    house_service_point_id character varying,
    new_spid character varying(50),
    new_spid_pv character varying(50),
    nem_agreement_date date
);


ALTER TABLE public."PVServicePointIDs" OWNER TO sepgroup;

--
-- Name: TABLE "PVServicePointIDs"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "PVServicePointIDs" IS 'Contains service point data for one-meter and two-meter PV installations. --Daniel Zhang (張道博)';


--
-- Name: PowerMeterEvents; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "PowerMeterEvents" (
    dtype text,
    id bigint NOT NULL,
    event_category integer,
    el_epoch_num text,
    el_seq_num text,
    event_ack_status text,
    event_text text,
    event_time timestamp without time zone NOT NULL,
    generic_col_1 text,
    generic_col_2 text,
    generic_col_3 text,
    generic_col_4 text,
    generic_col_5 text,
    generic_col_6 text,
    generic_col_7 text,
    generic_col_8 text,
    generic_col_9 text,
    generic_col_10 text,
    insert_ts timestamp without time zone,
    job_id text,
    event_key integer,
    nic_reboot_count text,
    seconds_since_reboot text,
    event_severity text,
    source_id integer,
    update_ts timestamp without time zone,
    updated_by_user text,
    event_ack_note text
);


ALTER TABLE public."PowerMeterEvents" OWNER TO sepgroup;

--
-- Name: Register; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "Register" (
    tier_id bigint NOT NULL,
    register_id bigint NOT NULL,
    cumulative_demand real,
    demand_uom character varying,
    number smallint NOT NULL,
    summation real,
    summation_uom character varying
);


ALTER TABLE public."Register" OWNER TO sepgroup;

--
-- Name: RegisterData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "RegisterData" (
    meter_data_id bigint NOT NULL,
    register_data_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    number_reads smallint NOT NULL
);


ALTER TABLE public."RegisterData" OWNER TO sepgroup;

--
-- Name: RegisterRead; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "RegisterRead" (
    register_data_id bigint NOT NULL,
    register_read_id bigint NOT NULL,
    gateway_collected_time timestamp without time zone NOT NULL,
    read_time timestamp without time zone NOT NULL,
    register_read_source character varying NOT NULL,
    season smallint NOT NULL
);


ALTER TABLE public."RegisterRead" OWNER TO sepgroup;

--
-- Name: TapData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "TapData" (
    "timestamp" timestamp without time zone,
    tap_setting real,
    substation character varying(20) DEFAULT 'wailea'::character varying,
    transformer character varying(4) DEFAULT '4'::character varying
);


ALTER TABLE public."TapData" OWNER TO sepgroup;

--
-- Name: Tier; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "Tier" (
    register_read_id bigint NOT NULL,
    tier_id bigint NOT NULL,
    number smallint NOT NULL
);


ALTER TABLE public."Tier" OWNER TO sepgroup;

--
-- Name: TransformerData; Type: TABLE; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE TABLE "TransformerData" (
    transformer character varying NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    vlt_a double precision,
    vlt_b double precision,
    vlt_c double precision,
    volt double precision,
    upload_date date DEFAULT now()
);


ALTER TABLE public."TransformerData" OWNER TO sepgroup;

--
-- Name: TABLE "TransformerData"; Type: COMMENT; Schema: public; Owner: sepgroup
--

COMMENT ON TABLE "TransformerData" IS 'Data from MECO scada data extract (comes with circuit data and irradiance data)
vlt_a, vlt_b, and vlt_c = kV (1,000 volts) measured phase to neutral
volt (e.g. 121.5) = reference voltage measurement (measured in volts) for the load tap changer
';


--
-- Name: WeatherNOAA; Type: TABLE; Schema: public; Owner: daniel; Tablespace: 
--

CREATE TABLE "WeatherNOAA" (
    wban character varying NOT NULL,
    datetime timestamp(6) without time zone NOT NULL,
    station_type smallint,
    sky_condition character varying,
    sky_condition_flag character varying,
    visibility character varying,
    visibility_flag character varying,
    weather_type character varying,
    weather_type_flag character varying,
    dry_bulb_farenheit character varying,
    dry_bulb_farenheit_flag character varying,
    dry_bulb_celsius character varying,
    dry_bulb_celsius_flag character varying,
    wet_bulb_farenheit character varying,
    wet_bulb_farenheit_flag character varying,
    wet_bulb_celsius character varying,
    wet_bulb_celsius_flag character varying,
    dew_point_farenheit character varying,
    dew_point_farenheit_flag character varying,
    dew_point_celsius character varying,
    dew_point_celsius_flag character varying,
    relative_humidity character varying,
    relative_humidity_flag character varying,
    wind_speed character varying,
    wind_speed_flag character varying,
    wind_direction character varying,
    wind_direction_flag character varying,
    value_for_wind_character character varying,
    value_for_wind_character_flag character varying,
    station_pressure character varying,
    station_pressure_flag character varying,
    pressure_tendency character varying,
    pressure_tendency_flag character varying,
    pressure_change character varying,
    pressure_change_flag character varying,
    sea_level_pressure character varying,
    sea_level_pressure_flag character varying,
    record_type character varying NOT NULL,
    record_type_flag character varying,
    hourly_precip character varying,
    hourly_precip_flag character varying,
    altimeter character varying,
    altimeter_flag character varying,
    created timestamp(6) with time zone NOT NULL
);


ALTER TABLE public."WeatherNOAA" OWNER TO daniel;

--
-- Name: COLUMN "WeatherNOAA".created; Type: COMMENT; Schema: public; Owner: daniel
--

COMMENT ON COLUMN "WeatherNOAA".created IS 'Time that record was created.';


--
-- Name: _IrradianceFifteenMinIntervals; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "_IrradianceFifteenMinIntervals" (
    sensor_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone
);


ALTER TABLE public."_IrradianceFifteenMinIntervals" OWNER TO postgres;

--
-- Name: TABLE "_IrradianceFifteenMinIntervals"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE "_IrradianceFifteenMinIntervals" IS 'Private table used by 15 min aggregation operations. --Daniel Zhang (張道博)';


--
-- Name: az_ashkan1; Type: VIEW; Schema: public; Owner: christian
--

CREATE VIEW az_ashkan1 AS
    SELECT DISTINCT avg("IrradianceData".irradiance_w_per_m2) AS "irradiance w/m2", date_trunc('hour'::text, "IrradianceData"."timestamp") AS "time hr", avg("KiheiSCADATemperatureHumidity".met_air_temp_degf) AS temperature, avg("KiheiSCADATemperatureHumidity".met_rel_humid_pct) AS "humidity pct" FROM ("IrradianceData" JOIN "KiheiSCADATemperatureHumidity" ON (("IrradianceData"."timestamp" = "KiheiSCADATemperatureHumidity"."timestamp"))) GROUP BY "IrradianceData"."timestamp" ORDER BY date_trunc('hour'::text, "IrradianceData"."timestamp") LIMIT 1000;


ALTER TABLE public.az_ashkan1 OWNER TO christian;

--
-- Name: az_houses_all_with_smart_meter; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_houses_all_with_smart_meter AS
    SELECT "MeterLocationHistory".address, "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_id AS new_service_point_id FROM "MeterLocationHistory" WHERE ("MeterLocationHistory".uninstalled IS NULL);


ALTER TABLE public.az_houses_all_with_smart_meter OWNER TO eileen;

--
-- Name: az_houses_with_no_pv; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_houses_with_no_pv AS
    SELECT az_houses_all_with_smart_meter.address, az_houses_all_with_smart_meter.service_point_id FROM (az_houses_all_with_smart_meter JOIN "PVServicePointIDs" ON ((("PVServicePointIDs".old_house_service_point_id)::text = (az_houses_all_with_smart_meter.service_point_id)::text))) WHERE ((az_houses_all_with_smart_meter.service_point_id)::text = ("PVServicePointIDs".old_house_service_point_id)::text);


ALTER TABLE public.az_houses_with_no_pv OWNER TO eileen;

--
-- Name: az_houses_with_pv_and_pv_meter; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_houses_with_pv_and_pv_meter AS
    SELECT "PVServicePointIDs".old_pv_service_point_id AS pv_service_point_id, "PVServicePointIDs".old_house_service_point_id AS house_service_point_id, "PVServicePointIDs".has_meter, "PVServicePointIDs".has_separate_pv_meter, "PVServicePointIDs".street FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".has_meter = 1) AND ("PVServicePointIDs".has_separate_pv_meter = 1));


ALTER TABLE public.az_houses_with_pv_and_pv_meter OWNER TO eileen;

--
-- Name: az_houses_with_pv_no_extra_meter; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_houses_with_pv_no_extra_meter AS
    SELECT "PVServicePointIDs".old_pv_service_point_id AS pv_service_point_id, "PVServicePointIDs".old_house_service_point_id AS house_service_point_id, "PVServicePointIDs".has_meter, "PVServicePointIDs".has_separate_pv_meter, "PVServicePointIDs".street FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".has_meter = 1) AND ("PVServicePointIDs".has_separate_pv_meter = 0));


ALTER TABLE public.az_houses_with_pv_no_extra_meter OWNER TO eileen;

--
-- Name: az_noaa_weather_data; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_noaa_weather_data AS
    SELECT "WeatherNOAA".datetime, "WeatherNOAA".dry_bulb_farenheit, "WeatherNOAA".relative_humidity FROM "WeatherNOAA" WHERE ((("WeatherNOAA".dry_bulb_farenheit)::text <> 'M'::text) AND (("WeatherNOAA".relative_humidity)::text <> 'M'::text)) ORDER BY "WeatherNOAA".datetime;


ALTER TABLE public.az_noaa_weather_data OWNER TO eileen;

--
-- Name: readings_by_meter_location_history; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW readings_by_meter_location_history AS
    SELECT "MeterLocationHistory".meter_name, "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".location, "MeterLocationHistory".address, "MeterLocationHistory".latitude, "MeterLocationHistory".longitude, "MeterLocationHistory".installed, "MeterLocationHistory".uninstalled, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "Interval".end_time, "MeterData".meter_data_id FROM (((("MeterLocationHistory" JOIN "MeterData" ON ((("MeterLocationHistory".meter_name)::bpchar = "MeterData".meter_name))) JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN "Reading" ON (((("Interval".interval_id = "Reading".interval_id) AND ("Interval".end_time >= "MeterLocationHistory".installed)) AND CASE WHEN ("MeterLocationHistory".uninstalled IS NULL) THEN true ELSE ("Interval".end_time < "MeterLocationHistory".uninstalled) END)));


ALTER TABLE public.readings_by_meter_location_history OWNER TO eileen;

--
-- Name: cd_readings_channel_as_columns_by_service_point; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW cd_readings_channel_as_columns_by_service_point AS
    SELECT readings_by_meter_location_history_new_spid.service_point_id, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Energy to House kwH", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Energy from House kwH(rec)", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Net Energy to House KwH", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "voltage at house", readings_by_meter_location_history_new_spid.end_time, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS service_point_latitude, max(readings_by_meter_location_history_new_spid.service_point_longitude) AS service_point_longitude, max((readings_by_meter_location_history_new_spid.location)::text) AS "location_ID", max((readings_by_meter_location_history_new_spid.address)::text) AS address, max(readings_by_meter_location_history_new_spid.latitude) AS location_latitude, max(readings_by_meter_location_history_new_spid.longitude) AS location_longitude FROM readings_by_meter_location_history readings_by_meter_location_history_new_spid GROUP BY readings_by_meter_location_history_new_spid.service_point_id, readings_by_meter_location_history_new_spid.end_time;


ALTER TABLE public.cd_readings_channel_as_columns_by_service_point OWNER TO eileen;

--
-- Name: az_readings_channel_as_columns_by_spid; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_readings_channel_as_columns_by_spid AS
    SELECT cd_readings_channel_as_columns_by_service_point.service_point_id, cd_readings_channel_as_columns_by_service_point."Energy to House kwH", cd_readings_channel_as_columns_by_service_point."Energy from House kwH(rec)", cd_readings_channel_as_columns_by_service_point."Net Energy to House KwH", cd_readings_channel_as_columns_by_service_point."voltage at house", cd_readings_channel_as_columns_by_service_point.end_time, cd_readings_channel_as_columns_by_service_point.address FROM cd_readings_channel_as_columns_by_service_point WHERE ((cd_readings_channel_as_columns_by_service_point.service_point_id)::text = '98751'::text);


ALTER TABLE public.az_readings_channel_as_columns_by_spid OWNER TO eileen;

--
-- Name: readings_channel_as_columns_by_new_spid; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW readings_channel_as_columns_by_new_spid AS
    SELECT readings_by_meter_location_history_new_spid.service_point_id, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Energy to House kwH", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Energy from House kwH(rec)", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Net Energy to House KwH", max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "voltage at house", readings_by_meter_location_history_new_spid.end_time, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS service_point_latitude, max(readings_by_meter_location_history_new_spid.service_point_longitude) AS service_point_longitude, max((readings_by_meter_location_history_new_spid.location)::text) AS "location_ID", max((readings_by_meter_location_history_new_spid.address)::text) AS address, max(readings_by_meter_location_history_new_spid.latitude) AS location_latitude, max(readings_by_meter_location_history_new_spid.longitude) AS location_longitude FROM readings_by_meter_location_history readings_by_meter_location_history_new_spid GROUP BY readings_by_meter_location_history_new_spid.service_point_id, readings_by_meter_location_history_new_spid.end_time;


ALTER TABLE public.readings_channel_as_columns_by_new_spid OWNER TO eileen;

--
-- Name: az_readings_channels_as_columns_new_spid; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW az_readings_channels_as_columns_new_spid AS
    SELECT readings_channel_as_columns_by_new_spid.service_point_id, readings_channel_as_columns_by_new_spid."Energy to House kwH", readings_channel_as_columns_by_new_spid."Energy from House kwH(rec)", readings_channel_as_columns_by_new_spid."Net Energy to House KwH", readings_channel_as_columns_by_new_spid."voltage at house", readings_channel_as_columns_by_new_spid.end_time, readings_channel_as_columns_by_new_spid.address FROM readings_channel_as_columns_by_new_spid;


ALTER TABLE public.az_readings_channels_as_columns_new_spid OWNER TO eileen;

--
-- Name: cd_20130706-20130711; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW "cd_20130706-20130711" AS
    SELECT "TransformerData".transformer, "TransformerData"."timestamp", "TransformerData".vlt_a FROM "TransformerData" WHERE (("TransformerData"."timestamp" >= '2013-07-06 17:03:00'::timestamp without time zone) AND ("TransformerData"."timestamp" <= '2013-07-11 14:32:00'::timestamp without time zone));


ALTER TABLE public."cd_20130706-20130711" OWNER TO eileen;

--
-- Name: cd_20130709-20130710; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW "cd_20130709-20130710" AS
    SELECT "TransformerData".transformer, "TransformerData"."timestamp", "TransformerData".vlt_a FROM "TransformerData" WHERE (("TransformerData"."timestamp" >= '2013-07-07 17:00:00'::timestamp without time zone) AND ("TransformerData"."timestamp" <= '2013-07-10 17:00:00'::timestamp without time zone));


ALTER TABLE public."cd_20130709-20130710" OWNER TO eileen;

--
-- Name: cd_meter_ids_for_houses_with_pv_with_locations; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW cd_meter_ids_for_houses_with_pv_with_locations AS
    SELECT "LocationRecords".device_util_id, "LocationRecords".service_pt_longitude, "LocationRecords".service_pt_latitude, "LocationRecords".address1 FROM ("LocationRecords" LEFT JOIN "MSG_PV_Data" ON ((("LocationRecords".device_util_id)::text = ("MSG_PV_Data".util_device_id)::text))) WHERE ("MSG_PV_Data".util_device_id IS NOT NULL);


ALTER TABLE public.cd_meter_ids_for_houses_with_pv_with_locations OWNER TO eileen;

--
-- Name: readings_unfiltered; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW readings_unfiltered AS
    SELECT "Interval".end_time, "MeterData".meter_name, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "IntervalReadData".start_time, "IntervalReadData".end_time AS ird_end_time, "MeterData".meter_data_id, "Reading".interval_id FROM ((("MeterData" JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN "Reading" ON (("Interval".interval_id = "Reading".interval_id)));


ALTER TABLE public.readings_unfiltered OWNER TO postgres;

--
-- Name: VIEW readings_unfiltered; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW readings_unfiltered IS 'All readings along with their end times by meter. @author Daniel Zhang (張道博)';


--
-- Name: cd_energy_voltages_for_houses_with_pv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW cd_energy_voltages_for_houses_with_pv AS
    SELECT cd_meter_ids_for_houses_with_pv_with_locations.device_util_id, view_readings_with_meter_id_unsorted.end_time, max(CASE WHEN (view_readings_with_meter_id_unsorted.channel = (1)::smallint) THEN view_readings_with_meter_id_unsorted.value ELSE NULL::real END) AS "Energy to House kwH", zero_to_null(max(CASE WHEN (view_readings_with_meter_id_unsorted.channel = (4)::smallint) THEN view_readings_with_meter_id_unsorted.value ELSE NULL::real END)) AS "Voltage", max(cd_meter_ids_for_houses_with_pv_with_locations.service_pt_longitude) AS service_pt_longitude, max(cd_meter_ids_for_houses_with_pv_with_locations.service_pt_latitude) AS service_pt_latitude, max((cd_meter_ids_for_houses_with_pv_with_locations.address1)::text) AS address1 FROM (cd_meter_ids_for_houses_with_pv_with_locations JOIN readings_unfiltered view_readings_with_meter_id_unsorted ON (((cd_meter_ids_for_houses_with_pv_with_locations.device_util_id)::bpchar = view_readings_with_meter_id_unsorted.meter_name))) WHERE ((view_readings_with_meter_id_unsorted.channel = (1)::smallint) OR (view_readings_with_meter_id_unsorted.channel = (4)::smallint)) GROUP BY cd_meter_ids_for_houses_with_pv_with_locations.device_util_id, view_readings_with_meter_id_unsorted.end_time;


ALTER TABLE public.cd_energy_voltages_for_houses_with_pv OWNER TO postgres;

--
-- Name: cd_houses_with_pv_no_pv_meter; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW cd_houses_with_pv_no_pv_meter AS
    SELECT "PVServicePointIDs".old_pv_service_point_id AS pv_service_point_id, "PVServicePointIDs".old_house_service_point_id AS house_service_point_id, "PVServicePointIDs"."PV_Mod_size_kW", "PVServicePointIDs".inverter_model, "PVServicePointIDs"."size_kW", "PVServicePointIDs"."system_cap_kW", "PVServicePointIDs".bat, "PVServicePointIDs".sub, "PVServicePointIDs".circuit, "PVServicePointIDs".date_uploaded, "PVServicePointIDs".has_meter, "PVServicePointIDs".has_separate_pv_meter, "PVServicePointIDs"."add_cap_kW", "PVServicePointIDs".upgraded_total_kw, "PVServicePointIDs".street, "PVServicePointIDs".city, "PVServicePointIDs".state, "PVServicePointIDs".zip, "PVServicePointIDs".month_installed, "PVServicePointIDs".year_installed, "PVServicePointIDs".notes FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".old_pv_service_point_id IS NULL) AND ("PVServicePointIDs".old_house_service_point_id IS NOT NULL));


ALTER TABLE public.cd_houses_with_pv_no_pv_meter OWNER TO eileen;

--
-- Name: cd_monthly_summary; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW cd_monthly_summary AS
    SELECT cd_readings_channel_as_columns_by_service_point.service_point_id, sum(cd_readings_channel_as_columns_by_service_point."Energy to House kwH") AS total_energy_to_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Energy from House kwH(rec)") AS total_energy_from_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Net Energy to House KwH") AS total_net_energy_kwh, avg(cd_readings_channel_as_columns_by_service_point."voltage at house") AS avg, date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time) AS month, max(cd_readings_channel_as_columns_by_service_point.service_point_latitude) AS sp_latitude, max(cd_readings_channel_as_columns_by_service_point.service_point_longitude) AS sp_longtidue, max(cd_readings_channel_as_columns_by_service_point."location_ID") AS location_id, max(cd_readings_channel_as_columns_by_service_point.address) AS address, max(cd_readings_channel_as_columns_by_service_point.location_latitude) AS location_latitude, max(cd_readings_channel_as_columns_by_service_point.location_longitude) AS location_longitude, (((count(cd_readings_channel_as_columns_by_service_point.end_time))::double precision / (4)::double precision) / (24)::double precision) AS count_day FROM cd_readings_channel_as_columns_by_service_point GROUP BY cd_readings_channel_as_columns_by_service_point.service_point_id, date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time);


ALTER TABLE public.cd_monthly_summary OWNER TO eileen;

--
-- Name: count_of_meters_not_in_mlh; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW count_of_meters_not_in_mlh AS
    SELECT abs(((SELECT count(DISTINCT "MeterData".meter_name) AS count FROM "MeterData") - (SELECT count(DISTINCT "MeterLocationHistory".meter_name) AS count FROM "MeterLocationHistory"))) AS meter_count_not_in_mlh;


ALTER TABLE public.count_of_meters_not_in_mlh OWNER TO postgres;

--
-- Name: VIEW count_of_meters_not_in_mlh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW count_of_meters_not_in_mlh IS 'Counts all meters not in MLH. The result should be zero. @author Daniel Zhang (張道博)';


--
-- Name: readings_after_uninstall; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW readings_after_uninstall AS
    SELECT "MeterLocationHistory".meter_name, "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".location, "MeterLocationHistory".address, "MeterLocationHistory".latitude, "MeterLocationHistory".longitude, "MeterLocationHistory".installed, "MeterLocationHistory".uninstalled, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "Interval".end_time, "MeterData".meter_data_id FROM (((("MeterLocationHistory" JOIN "MeterData" ON ((("MeterLocationHistory".meter_name)::bpchar = "MeterData".meter_name))) JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN "Reading" ON ((("Interval".interval_id = "Reading".interval_id) AND ("Interval".end_time >= "MeterLocationHistory".uninstalled))));


ALTER TABLE public.readings_after_uninstall OWNER TO postgres;

--
-- Name: VIEW readings_after_uninstall; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW readings_after_uninstall IS 'Readings that have been recorded after a meter''s uninstall date. @author Daniel Zhang (張道博)';


--
-- Name: readings_before_install; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW readings_before_install AS
    SELECT "MeterLocationHistory".meter_name, "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".location, "MeterLocationHistory".address, "MeterLocationHistory".latitude, "MeterLocationHistory".longitude, "MeterLocationHistory".installed, "MeterLocationHistory".uninstalled, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "Interval".end_time, "MeterData".meter_data_id FROM (((("MeterLocationHistory" JOIN "MeterData" ON ((("MeterLocationHistory".meter_name)::bpchar = "MeterData".meter_name))) JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN "Reading" ON ((("Interval".interval_id = "Reading".interval_id) AND ("Interval".end_time < "MeterLocationHistory".installed))));


ALTER TABLE public.readings_before_install OWNER TO postgres;

--
-- Name: VIEW readings_before_install; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW readings_before_install IS 'Readings that have been recorded before a meter''s install date. @author Daniel Zhang (張道博)';


--
-- Name: count_of_non_mlh_readings; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW count_of_non_mlh_readings AS
    SELECT ((SELECT count(*) AS count FROM readings_before_install) + (SELECT count(*) AS count FROM readings_after_uninstall));


ALTER TABLE public.count_of_non_mlh_readings OWNER TO postgres;

--
-- Name: VIEW count_of_non_mlh_readings; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW count_of_non_mlh_readings IS 'Counts readings not in MLH. @author Daniel Zhang (張道博)';


--
-- Name: count_of_readings_and_meters_by_day; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW count_of_readings_and_meters_by_day AS
    SELECT date_trunc('day'::text, view_readings_with_meter_id_unsorted.end_time) AS "Day", count(view_readings_with_meter_id_unsorted.value) AS "Reading Count", count(DISTINCT view_readings_with_meter_id_unsorted.meter_name) AS "Meter Count", (count(view_readings_with_meter_id_unsorted.value) / count(DISTINCT view_readings_with_meter_id_unsorted.meter_name)) AS "Readings per Meter" FROM readings_unfiltered view_readings_with_meter_id_unsorted WHERE (view_readings_with_meter_id_unsorted.channel = 1) GROUP BY date_trunc('day'::text, view_readings_with_meter_id_unsorted.end_time) ORDER BY date_trunc('day'::text, view_readings_with_meter_id_unsorted.end_time);


ALTER TABLE public.count_of_readings_and_meters_by_day OWNER TO postgres;

--
-- Name: VIEW count_of_readings_and_meters_by_day; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW count_of_readings_and_meters_by_day IS 'Get counts of readings and meters per day. @author Daniel Zhang (張道博)';


--
-- Name: count_of_register_duplicates; Type: VIEW; Schema: public; Owner: daniel
--

CREATE VIEW count_of_register_duplicates AS
    SELECT "Register".number, "MeterData".meter_name, "RegisterRead".read_time, (count(*) - 1) AS "Duplicate Count" FROM (((("MeterData" JOIN "RegisterData" ON (("MeterData".meter_data_id = "RegisterData".meter_data_id))) JOIN "RegisterRead" ON (("RegisterData".register_data_id = "RegisterRead".register_data_id))) JOIN "Tier" ON (("RegisterRead".register_read_id = "Tier".register_read_id))) JOIN "Register" ON (("Tier".tier_id = "Register".tier_id))) GROUP BY "Register".number, "MeterData".meter_name, "RegisterRead".read_time HAVING ((count(*) - 1) > 0) ORDER BY "RegisterRead".read_time DESC, (count(*) - 1) DESC;


ALTER TABLE public.count_of_register_duplicates OWNER TO daniel;

--
-- Name: VIEW count_of_register_duplicates; Type: COMMENT; Schema: public; Owner: daniel
--

COMMENT ON VIEW count_of_register_duplicates IS 'Count of duplicates in the Register branch. @author Daniel Zhang (張道博)';


--
-- Name: dates_az_readings_channels_as_columns_new_spid; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_az_readings_channels_as_columns_new_spid AS
    SELECT az_readings_channels_as_columns_new_spid.service_point_id, az_readings_channels_as_columns_new_spid.address, min(az_readings_channels_as_columns_new_spid.end_time) AS start, max(az_readings_channels_as_columns_new_spid.end_time) AS "end" FROM az_readings_channels_as_columns_new_spid GROUP BY az_readings_channels_as_columns_new_spid.service_point_id, az_readings_channels_as_columns_new_spid.address;


ALTER TABLE public.dates_az_readings_channels_as_columns_new_spid OWNER TO eileen;

--
-- Name: dates_egauge_energy_autoload; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_egauge_energy_autoload AS
    SELECT "EgaugeEnergyAutoload".egauge_id, min("EgaugeEnergyAutoload".datetime) AS "E Start Date", max("EgaugeEnergyAutoload".datetime) AS "E Latest Date", ((count(*) / 60) / 24) AS "Days of Data" FROM "EgaugeEnergyAutoload" GROUP BY "EgaugeEnergyAutoload".egauge_id ORDER BY "EgaugeEnergyAutoload".egauge_id;


ALTER TABLE public.dates_egauge_energy_autoload OWNER TO eileen;

--
-- Name: dates_irradiance_data; Type: TABLE; Schema: public; Owner: eileen; Tablespace: 
--

CREATE TABLE dates_irradiance_data (
    sensor_id integer,
    latitude double precision,
    longitude double precision,
    count bigint,
    "Earliest Date" timestamp without time zone,
    "Latest Date" timestamp without time zone,
    name character varying
);


ALTER TABLE public.dates_irradiance_data OWNER TO eileen;

--
-- Name: dates_kihei_scada_temp_hum; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_kihei_scada_temp_hum AS
    SELECT min("KiheiSCADATemperatureHumidity"."timestamp") AS "Earliest date", max("KiheiSCADATemperatureHumidity"."timestamp") AS "Latest date" FROM "KiheiSCADATemperatureHumidity";


ALTER TABLE public.dates_kihei_scada_temp_hum OWNER TO eileen;

--
-- Name: dates_meter_read; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_meter_read AS
    SELECT "MeterData".util_device_id, min("Interval".end_time) AS earliest_date, max("IntervalReadData".end_time) AS latest_date FROM (("MeterData" JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) GROUP BY "MeterData".util_device_id;


ALTER TABLE public.dates_meter_read OWNER TO eileen;

--
-- Name: dates_powermeterevents; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_powermeterevents AS
    SELECT min("PowerMeterEvents".event_time) AS "First event in data", max("PowerMeterEvents".event_time) AS "Last event in data" FROM "PowerMeterEvents";


ALTER TABLE public.dates_powermeterevents OWNER TO eileen;

--
-- Name: dates_tap_data; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_tap_data AS
    SELECT "TapData".substation, "TapData".transformer, min("TapData"."timestamp") AS "earliest date", max("TapData"."timestamp") AS "latest date" FROM "TapData" GROUP BY "TapData".substation, "TapData".transformer;


ALTER TABLE public.dates_tap_data OWNER TO eileen;

--
-- Name: dates_transformer_data; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW dates_transformer_data AS
    SELECT min("TransformerData"."timestamp") AS "earliest date", max("TransformerData"."timestamp") AS "latest date" FROM "TransformerData";


ALTER TABLE public.dates_transformer_data OWNER TO eileen;

--
-- Name: deprecated_meter_ids_for_houses_without_pv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW deprecated_meter_ids_for_houses_without_pv AS
    SELECT "LocationRecords".device_util_id FROM ("LocationRecords" LEFT JOIN "MSG_PV_Data" ON ((("LocationRecords".device_util_id)::text = ("MSG_PV_Data".util_device_id)::text))) WHERE ("MSG_PV_Data".util_device_id IS NULL);


ALTER TABLE public.deprecated_meter_ids_for_houses_without_pv OWNER TO postgres;

--
-- Name: VIEW deprecated_meter_ids_for_houses_without_pv; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW deprecated_meter_ids_for_houses_without_pv IS 'Meter IDs for houses that do not have PV. @author Daniel Zhang (張道博)';


--
-- Name: z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero AS
    SELECT "_IrradianceFifteenMinIntervals".end_time, "_IrradianceFifteenMinIntervals".sensor_id, CASE WHEN ("AverageFifteenMinIrradianceData".irradiance_w_per_m2 IS NULL) THEN (0.0)::double precision ELSE "AverageFifteenMinIrradianceData".irradiance_w_per_m2 END AS irradiance_w_per_m2 FROM ("_IrradianceFifteenMinIntervals" LEFT JOIN "AverageFifteenMinIrradianceData" ON ((("_IrradianceFifteenMinIntervals".end_time = "AverageFifteenMinIrradianceData"."timestamp") AND ("_IrradianceFifteenMinIntervals".sensor_id = "AverageFifteenMinIrradianceData".sensor_id)))) WHERE (("_IrradianceFifteenMinIntervals".end_time >= (SELECT date_trunc('day'::text, min("AverageFifteenMinIrradianceData"."timestamp")) AS date_trunc FROM "AverageFifteenMinIrradianceData")) AND ("_IrradianceFifteenMinIntervals".end_time <= (SELECT date_trunc('day'::text, max("AverageFifteenMinIrradianceData"."timestamp")) AS date_trunc FROM "AverageFifteenMinIrradianceData"))) ORDER BY "_IrradianceFifteenMinIntervals".end_time, "_IrradianceFifteenMinIntervals".sensor_id;


ALTER TABLE public.z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero OWNER TO postgres;

--
-- Name: VIEW z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero IS 'Used internally for aggregating irradiance data. @author Daniel Zhang (張道博)';


--
-- Name: dz_count_of_fifteen_min_irradiance_intervals; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_count_of_fifteen_min_irradiance_intervals AS
    SELECT (count(*) / 4) AS cnt, date_trunc('day'::text, z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero.end_time) AS day FROM z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero GROUP BY date_trunc('day'::text, z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero.end_time);


ALTER TABLE public.dz_count_of_fifteen_min_irradiance_intervals OWNER TO postgres;

--
-- Name: dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero AS
    SELECT "_IrradianceFifteenMinIntervals".end_time, "_IrradianceFifteenMinIntervals".sensor_id, CASE WHEN ("AverageFifteenMinIrradianceData".irradiance_w_per_m2 IS NULL) THEN (0.0)::double precision ELSE "AverageFifteenMinIrradianceData".irradiance_w_per_m2 END AS irradiance_w_per_m2 FROM (("_IrradianceFifteenMinIntervals" LEFT JOIN "AverageFifteenMinIrradianceData" ON ((("_IrradianceFifteenMinIntervals".end_time = "AverageFifteenMinIrradianceData"."timestamp") AND ("_IrradianceFifteenMinIntervals".sensor_id = "AverageFifteenMinIrradianceData".sensor_id)))) JOIN dz_count_of_fifteen_min_irradiance_intervals ON (((date_trunc('day'::text, "_IrradianceFifteenMinIntervals".end_time) = dz_count_of_fifteen_min_irradiance_intervals.day) AND (dz_count_of_fifteen_min_irradiance_intervals.cnt = 96)))) WHERE (("_IrradianceFifteenMinIntervals".end_time >= (SELECT date_trunc('day'::text, min("AverageFifteenMinIrradianceData"."timestamp")) AS date_trunc FROM "AverageFifteenMinIrradianceData")) AND ("_IrradianceFifteenMinIntervals".end_time <= (SELECT date_trunc('day'::text, max("AverageFifteenMinIrradianceData"."timestamp")) AS date_trunc FROM "AverageFifteenMinIrradianceData"))) ORDER BY "_IrradianceFifteenMinIntervals".end_time, "_IrradianceFifteenMinIntervals".sensor_id;


ALTER TABLE public.dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero OWNER TO postgres;

--
-- Name: VIEW dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero IS 'Transformed irradiance data for use in analysis. @author Daniel Zhang (張道博)';


--
-- Name: dz_energy_voltages_for_houses_without_pv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_energy_voltages_for_houses_without_pv AS
    SELECT readings_by_meter_location_history_new_spid.meter_name, readings_by_meter_location_history_new_spid.end_time, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS "Energy to House kwH", zero_to_null(max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END)) AS "Voltage", max(readings_by_meter_location_history_new_spid.service_point_longitude) AS service_pt_longitude, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS service_pt_latitude, max((readings_by_meter_location_history_new_spid.address)::text) AS address FROM (deprecated_meter_ids_for_houses_without_pv meter_ids_for_houses_without_pv JOIN readings_by_meter_location_history readings_by_meter_location_history_new_spid ON (((meter_ids_for_houses_without_pv.device_util_id)::text = (readings_by_meter_location_history_new_spid.meter_name)::text))) WHERE ((readings_by_meter_location_history_new_spid.channel = (1)::smallint) OR (readings_by_meter_location_history_new_spid.channel = (4)::smallint)) GROUP BY readings_by_meter_location_history_new_spid.meter_name, readings_by_meter_location_history_new_spid.end_time;


ALTER TABLE public.dz_energy_voltages_for_houses_without_pv OWNER TO postgres;

--
-- Name: VIEW dz_energy_voltages_for_houses_without_pv; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_energy_voltages_for_houses_without_pv IS 'Energy and voltages for houses without PV limited by Meter Location History. @author Daniel Zhang (張道博)';


--
-- Name: dz_irradiance_fifteen_min_intervals_plus_one_year; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_irradiance_fifteen_min_intervals_plus_one_year AS
    SELECT ((SELECT (min("IrradianceData"."timestamp"))::date AS min FROM "IrradianceData") + ((n.n || ' minutes'::text))::interval) AS start_time, ((SELECT (min("IrradianceData"."timestamp"))::date AS min FROM "IrradianceData") + (((n.n + 15) || ' minutes'::text))::interval) AS end_time FROM generate_series(0, ((((SELECT ((max("IrradianceData"."timestamp"))::date - (min("IrradianceData"."timestamp"))::date) FROM "IrradianceData") + 366) * 24) * 60), 15) n(n);


ALTER TABLE public.dz_irradiance_fifteen_min_intervals_plus_one_year OWNER TO postgres;

--
-- Name: dz_monthly_energy_summary_double_pv_meter; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_monthly_energy_summary_double_pv_meter AS
    SELECT max((readings_by_meter_location_history_new_spid.service_point_id)::text) AS service_point_id, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_to_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_from_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_net_energy_kwh, avg(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS avg, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text) AS service_month, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS sp_latitude, max(readings_by_meter_location_history_new_spid.service_point_longitude) AS sp_longitude, max((readings_by_meter_location_history_new_spid.location)::text) AS location_id, max((readings_by_meter_location_history_new_spid.address)::text) AS address, max(readings_by_meter_location_history_new_spid.latitude) AS location_latitude, max(readings_by_meter_location_history_new_spid.longitude) AS location_longitude, ((count(readings_by_meter_location_history_new_spid.end_time) / 4) / 24) AS count_day FROM (readings_by_meter_location_history readings_by_meter_location_history_new_spid JOIN "PVServicePointIDs" ON ((((readings_by_meter_location_history_new_spid.service_point_id)::text = ("PVServicePointIDs".old_house_service_point_id)::text) OR ((readings_by_meter_location_history_new_spid.service_point_id)::text = ("PVServicePointIDs".old_pv_service_point_id)::text)))) WHERE ("PVServicePointIDs".old_pv_service_point_id IS NOT NULL) GROUP BY readings_by_meter_location_history_new_spid.service_point_id, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text);


ALTER TABLE public.dz_monthly_energy_summary_double_pv_meter OWNER TO postgres;

--
-- Name: VIEW dz_monthly_energy_summary_double_pv_meter; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_monthly_energy_summary_double_pv_meter IS 'Monthly energy summary for service points that have PV with a second PV meter. @author Daniel Zhang (張道博)';


--
-- Name: nonpv_service_point_ids; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW nonpv_service_point_ids AS
    SELECT "MeterLocationHistory".service_point_id, "MeterLocationHistory".meter_name, "MeterLocationHistory".installed, "MeterLocationHistory".uninstalled FROM "MeterLocationHistory" WHERE ((NOT (EXISTS (SELECT "PVServicePointIDs".pv_service_point_id FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".pv_service_point_id)::text = ("MeterLocationHistory".service_point_id)::text)))) OR (NOT (EXISTS (SELECT "PVServicePointIDs".house_service_point_id FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".house_service_point_id)::text = ("MeterLocationHistory".service_point_id)::text)))));


ALTER TABLE public.nonpv_service_point_ids OWNER TO postgres;

--
-- Name: VIEW nonpv_service_point_ids; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW nonpv_service_point_ids IS 'Service Point IDs, in the MLH,  that are not PV Service Point IDs. @author Daniel Zhang (張道博)';


--
-- Name: dz_monthly_energy_summary_for_nonpv_service_points; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_monthly_energy_summary_for_nonpv_service_points AS
    SELECT max((readings_by_meter_location_history_new_spid.service_point_id)::text) AS service_point_id, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_to_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_from_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_net_energy_kwh, avg(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS avg, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text) AS service_month, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS sp_latitude, max(readings_by_meter_location_history_new_spid.service_point_longitude) AS sp_longitude, max((readings_by_meter_location_history_new_spid.location)::text) AS location_id, max((readings_by_meter_location_history_new_spid.address)::text) AS address, max(readings_by_meter_location_history_new_spid.latitude) AS location_latitude, max(readings_by_meter_location_history_new_spid.longitude) AS location_longitude, ((count(readings_by_meter_location_history_new_spid.end_time) / 4) / 24) AS count_day FROM (readings_by_meter_location_history readings_by_meter_location_history_new_spid JOIN nonpv_service_point_ids nonpv_service_point_ids_v2 ON (((readings_by_meter_location_history_new_spid.service_point_id)::text = (nonpv_service_point_ids_v2.service_point_id)::text))) GROUP BY readings_by_meter_location_history_new_spid.service_point_id, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text);


ALTER TABLE public.dz_monthly_energy_summary_for_nonpv_service_points OWNER TO postgres;

--
-- Name: VIEW dz_monthly_energy_summary_for_nonpv_service_points; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_monthly_energy_summary_for_nonpv_service_points IS 'Monthly energy summary for Non-PV service points. @author Daniel Zhang (張道博)';


--
-- Name: dz_monthly_energy_summary_single_pv_meter; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_monthly_energy_summary_single_pv_meter AS
    SELECT max((readings_by_meter_location_history_new_spid.service_point_id)::text) AS service_point_id, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_to_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_energy_from_house_kwh, sum(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS total_net_energy_kwh, avg(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS avg, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text) AS service_month, max(readings_by_meter_location_history_new_spid.service_point_latitude) AS sp_latitude, max(readings_by_meter_location_history_new_spid.service_point_longitude) AS sp_longitude, max((readings_by_meter_location_history_new_spid.location)::text) AS location_id, max((readings_by_meter_location_history_new_spid.address)::text) AS address, max(readings_by_meter_location_history_new_spid.latitude) AS location_latitude, max(readings_by_meter_location_history_new_spid.longitude) AS location_longitude, ((count(readings_by_meter_location_history_new_spid.end_time) / 4) / 24) AS count_day FROM (readings_by_meter_location_history readings_by_meter_location_history_new_spid JOIN "PVServicePointIDs" ON (((readings_by_meter_location_history_new_spid.service_point_id)::text = ("PVServicePointIDs".old_house_service_point_id)::text))) WHERE ("PVServicePointIDs".old_pv_service_point_id IS NULL) GROUP BY readings_by_meter_location_history_new_spid.service_point_id, to_char(date_trunc('month'::text, readings_by_meter_location_history_new_spid.end_time), 'yyyy-mm'::text);


ALTER TABLE public.dz_monthly_energy_summary_single_pv_meter OWNER TO postgres;

--
-- Name: VIEW dz_monthly_energy_summary_single_pv_meter; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_monthly_energy_summary_single_pv_meter IS 'Monthly energy summary for service points that have PV but NO second PV meter. @author Daniel Zhang (張道博)';


--
-- Name: dz_nonpv_addresses_service_points; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_nonpv_addresses_service_points AS
    SELECT DISTINCT mlh.service_point_id, mlh.address, mlh.uninstalled, mlh.installed FROM "MeterLocationHistory" mlh WHERE ((mlh.uninstalled IS NULL) AND (NOT (EXISTS (SELECT "PVServicePointIDs".pv_service_point_id FROM "PVServicePointIDs" WHERE ((("PVServicePointIDs".pv_service_point_id)::text = (mlh.service_point_id)::text) OR (("PVServicePointIDs".house_service_point_id)::text = (mlh.service_point_id)::text))))));


ALTER TABLE public.dz_nonpv_addresses_service_points OWNER TO postgres;

--
-- Name: nonpv_mlh; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW nonpv_mlh AS
    SELECT "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_height, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".notes, "MeterLocationHistory".longitude, "MeterLocationHistory".latitude, "MeterLocationHistory".city, "MeterLocationHistory".address, "MeterLocationHistory".location, "MeterLocationHistory".uninstalled, "MeterLocationHistory".installed, "MeterLocationHistory".mac_address, "MeterLocationHistory".meter_name FROM "MeterLocationHistory" WHERE (NOT (EXISTS (SELECT "PVServicePointIDs".pv_service_point_id FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".pv_service_point_id)::text = ("MeterLocationHistory".service_point_id)::text))));


ALTER TABLE public.nonpv_mlh OWNER TO postgres;

--
-- Name: VIEW nonpv_mlh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW nonpv_mlh IS 'This is the Meter Location History for nonPV service points. @author Daniel Zhang (張道博)';


--
-- Name: dz_pv_interval_ids; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_pv_interval_ids AS
    SELECT readings_unfiltered.interval_id, readings_unfiltered.value, readings_unfiltered.channel, readings_unfiltered.end_time, readings_unfiltered.meter_name FROM (nonpv_mlh JOIN readings_unfiltered ON (((nonpv_mlh.meter_name)::bpchar = readings_unfiltered.meter_name))) WHERE ((readings_unfiltered.channel = 2::smallint) AND (readings_unfiltered.value > 0::real));


ALTER TABLE public.dz_pv_interval_ids OWNER TO postgres;

--
-- Name: VIEW dz_pv_interval_ids; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_pv_interval_ids IS 'Provides interval IDs for readings where channel 2 has energy > 0.0. @author Daniel Zhang (張道博)';


--
-- Name: dz_pv_readings_in_nonpv_mlh; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_pv_readings_in_nonpv_mlh AS
    SELECT nonpv_mlh.service_point_id, readings_unfiltered.end_time, readings_unfiltered.meter_name, readings_unfiltered.channel, readings_unfiltered.raw_value, readings_unfiltered.value, readings_unfiltered.uom, readings_unfiltered.start_time, readings_unfiltered.ird_end_time, readings_unfiltered.meter_data_id, readings_unfiltered.interval_id FROM ((dz_pv_interval_ids JOIN readings_unfiltered ON ((dz_pv_interval_ids.interval_id = readings_unfiltered.interval_id))) JOIN nonpv_mlh ON ((dz_pv_interval_ids.meter_name = (nonpv_mlh.meter_name)::bpchar)));


ALTER TABLE public.dz_pv_readings_in_nonpv_mlh OWNER TO postgres;

--
-- Name: VIEW dz_pv_readings_in_nonpv_mlh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_pv_readings_in_nonpv_mlh IS 'A report of readings that are in the MLH but do not have PV service points IDs. @author Daniel Zhang (張道博)';


--
-- Name: dz_summary_pv_readings_in_nonpv_mlh; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dz_summary_pv_readings_in_nonpv_mlh AS
    SELECT dz_pv_readings_in_nonpv_mlh.meter_name, dz_pv_readings_in_nonpv_mlh.service_point_id, min(dz_pv_readings_in_nonpv_mlh.end_time) AS first_reading_time, max(dz_pv_readings_in_nonpv_mlh.end_time) AS last_reading_time FROM dz_pv_readings_in_nonpv_mlh GROUP BY dz_pv_readings_in_nonpv_mlh.meter_name, dz_pv_readings_in_nonpv_mlh.service_point_id;


ALTER TABLE public.dz_summary_pv_readings_in_nonpv_mlh OWNER TO postgres;

--
-- Name: VIEW dz_summary_pv_readings_in_nonpv_mlh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dz_summary_pv_readings_in_nonpv_mlh IS 'Summary of service points and meters in the MLH that have PV readings but do not have PV Service Point IDs. @author Daniel Zhang (張道博)';


--
-- Name: eGauge_view_with_filters; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW "eGauge_view_with_filters" AS
    SELECT "EgaugeEnergyAutoload".egauge_id AS "eGauge ID", "EgaugeEnergyAutoload".use_kw, "EgaugeEnergyAutoload".ac_kw, "EgaugeEnergyAutoload".clotheswasher_kw, "EgaugeEnergyAutoload".dryer_kw, "EgaugeEnergyAutoload".garage_ac_kw, "EgaugeEnergyAutoload".large_ac_kw, "EgaugeEnergyAutoload".large_ac_usage_kw, "EgaugeEnergyAutoload".oven_kw, "EgaugeEnergyAutoload".range_kw, "EgaugeEnergyAutoload".refrigerator_kw, "EgaugeEnergyAutoload".rest_of_house_usage_kw AS rest_of_house_kw, "EgaugeEnergyAutoload".stove_kw, "EgaugeEnergyAutoload".oven_and_microwave_kw AS oven_and_microwave, "EgaugeEnergyAutoload".shop_kw, "EgaugeEnergyAutoload".addition_kw, "EgaugeEnergyAutoload".dhw_load_control, "EgaugeEnergyAutoload".datetime FROM "EgaugeEnergyAutoload" WHERE (((((("EgaugeEnergyAutoload".use_kw < (20)::double precision) OR ("EgaugeEnergyAutoload".clotheswasher_kw < (7)::double precision)) OR ("EgaugeEnergyAutoload".dryer_kw < (7)::double precision)) OR ("EgaugeEnergyAutoload".ac_kw < (6)::double precision)) OR ("EgaugeEnergyAutoload".large_ac_kw < (6)::double precision)) OR ("EgaugeEnergyAutoload".garage_ac_kw < (6)::double precision));


ALTER TABLE public."eGauge_view_with_filters" OWNER TO eileen;

--
-- Name: egauge_energy_autoload_dates; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW egauge_energy_autoload_dates AS
    SELECT "EgaugeEnergyAutoload".egauge_id, min("EgaugeEnergyAutoload".datetime) AS "E Start Date", max("EgaugeEnergyAutoload".datetime) AS "E Latest Date", ((count(*) / 60) / 24) AS "Days of Data" FROM "EgaugeEnergyAutoload" GROUP BY "EgaugeEnergyAutoload".egauge_id ORDER BY "EgaugeEnergyAutoload".egauge_id;


ALTER TABLE public.egauge_energy_autoload_dates OWNER TO postgres;

--
-- Name: VIEW egauge_energy_autoload_dates; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW egauge_energy_autoload_dates IS 'Used by the MSG eGauge Service. @author Daniel Zhang (張道博)';


--
-- Name: event_data_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE event_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_data_id_seq OWNER TO sepgroup;

--
-- Name: event_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE event_data_id_seq OWNED BY "EventData".event_data_id;


--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO sepgroup;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE event_id_seq OWNED BY "Event".event_id;


--
-- Name: event_table_view; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW event_table_view AS
    SELECT DISTINCT "Event".event_name, "Event".event_time, "Event".event_text, "Event".event_data_id, "Event".event_id FROM "Event";


ALTER TABLE public.event_table_view OWNER TO eileen;

--
-- Name: interval_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE interval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.interval_id_seq OWNER TO sepgroup;

--
-- Name: interval_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE interval_id_seq OWNED BY "Interval".interval_id;


--
-- Name: intervalreaddata_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE intervalreaddata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.intervalreaddata_id_seq OWNER TO sepgroup;

--
-- Name: intervalreaddata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE intervalreaddata_id_seq OWNED BY "IntervalReadData".interval_read_data_id;


--
-- Name: irradiance_data; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW irradiance_data AS
    SELECT "IrradianceData".irradiance_w_per_m2, "IrradianceData".sensor_id, "IrradianceData"."timestamp", "IrradianceSensorInfo".latitude, "IrradianceSensorInfo".longitude, "IrradianceSensorInfo".name FROM ("IrradianceData" JOIN "IrradianceSensorInfo" ON (("IrradianceData".sensor_id = "IrradianceSensorInfo".sensor_id))) WHERE ("IrradianceData".irradiance_w_per_m2 > (0)::double precision);


ALTER TABLE public.irradiance_data OWNER TO eileen;

--
-- Name: locations_with_pv_service_points_ids; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW locations_with_pv_service_points_ids AS
    SELECT DISTINCT "MeterLocationHistory".location FROM ("PVServicePointIDs" JOIN "MeterLocationHistory" ON ((("PVServicePointIDs".old_pv_service_point_id)::text = ("MeterLocationHistory".old_service_point_id)::text)));


ALTER TABLE public.locations_with_pv_service_points_ids OWNER TO postgres;

--
-- Name: nonpv_mlh_v2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW nonpv_mlh_v2 AS
    SELECT "MeterLocationHistory".service_point_id, "MeterLocationHistory".service_point_height, "MeterLocationHistory".service_point_latitude, "MeterLocationHistory".service_point_longitude, "MeterLocationHistory".notes, "MeterLocationHistory".longitude, "MeterLocationHistory".latitude, "MeterLocationHistory".city, "MeterLocationHistory".address, "MeterLocationHistory".location, "MeterLocationHistory".uninstalled, "MeterLocationHistory".installed, "MeterLocationHistory".mac_address, "MeterLocationHistory".meter_name FROM "MeterLocationHistory" WHERE (NOT (EXISTS (SELECT "PVServicePointIDs".pv_service_point_id FROM "PVServicePointIDs" WHERE ((("PVServicePointIDs".pv_service_point_id)::text = ("MeterLocationHistory".service_point_id)::text) OR (("PVServicePointIDs".house_service_point_id)::text = ("MeterLocationHistory".service_point_id)::text)))));


ALTER TABLE public.nonpv_mlh_v2 OWNER TO postgres;

--
-- Name: VIEW nonpv_mlh_v2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW nonpv_mlh_v2 IS 'This is the Meter Location History for nonPV service points. @author Daniel Zhang (張道博)';


--
-- Name: meter_ids_for_service_points_without_pv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW meter_ids_for_service_points_without_pv AS
    SELECT nonpv_mlh_v2.meter_name, nonpv_mlh_v2.uninstalled, nonpv_mlh_v2.installed FROM nonpv_mlh_v2;


ALTER TABLE public.meter_ids_for_service_points_without_pv OWNER TO postgres;

--
-- Name: VIEW meter_ids_for_service_points_without_pv; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW meter_ids_for_service_points_without_pv IS 'These are the nonPV meters. @author Daniel Zhang (張道博)';


--
-- Name: meterdata_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE meterdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.meterdata_id_seq OWNER TO sepgroup;

--
-- Name: meterdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE meterdata_id_seq OWNED BY "MeterData".meter_data_id;


--
-- Name: monthly_energy_summary_all_meters; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW monthly_energy_summary_all_meters AS
    SELECT cd_readings_channel_as_columns_by_service_point.service_point_id, sum(cd_readings_channel_as_columns_by_service_point."Energy to House kwH") AS total_energy_to_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Energy from House kwH(rec)") AS total_energy_from_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Net Energy to House KwH") AS total_net_energy_kwh, avg(cd_readings_channel_as_columns_by_service_point."voltage at house") AS "avg voltage", date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time) AS month, max(cd_readings_channel_as_columns_by_service_point.service_point_latitude) AS sp_latitude, max(cd_readings_channel_as_columns_by_service_point.service_point_longitude) AS sp_longtidue, max(cd_readings_channel_as_columns_by_service_point."location_ID") AS location_id, max(cd_readings_channel_as_columns_by_service_point.address) AS address, max(cd_readings_channel_as_columns_by_service_point.location_latitude) AS location_latitude, max(cd_readings_channel_as_columns_by_service_point.location_longitude) AS location_longitude, (((count(cd_readings_channel_as_columns_by_service_point.end_time))::double precision / (4)::double precision) / (24)::double precision) AS count_day FROM cd_readings_channel_as_columns_by_service_point GROUP BY cd_readings_channel_as_columns_by_service_point.service_point_id, date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time);


ALTER TABLE public.monthly_energy_summary_all_meters OWNER TO eileen;

--
-- Name: monthly_energy_summary_houses_with_pv; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW monthly_energy_summary_houses_with_pv AS
    SELECT cd_readings_channel_as_columns_by_service_point.service_point_id, sum(cd_readings_channel_as_columns_by_service_point."Energy to House kwH") AS total_energy_to_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Energy from House kwH(rec)") AS total_energy_from_house_kwh, sum(cd_readings_channel_as_columns_by_service_point."Net Energy to House KwH") AS total_net_energy_kwh, avg(cd_readings_channel_as_columns_by_service_point."voltage at house") AS avg, date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time) AS month, max(cd_readings_channel_as_columns_by_service_point.service_point_latitude) AS sp_latitude, max(cd_readings_channel_as_columns_by_service_point.service_point_longitude) AS sp_longtidue, max(cd_readings_channel_as_columns_by_service_point."location_ID") AS location_id, max(cd_readings_channel_as_columns_by_service_point.address) AS address, max(cd_readings_channel_as_columns_by_service_point.location_latitude) AS location_latitude, max(cd_readings_channel_as_columns_by_service_point.location_longitude) AS location_longitude, (((count(cd_readings_channel_as_columns_by_service_point.end_time))::double precision / (4)::double precision) / (24)::double precision) AS count_day FROM (cd_readings_channel_as_columns_by_service_point JOIN "PVServicePointIDs" ON (((cd_readings_channel_as_columns_by_service_point.service_point_id)::text = ("PVServicePointIDs".old_house_service_point_id)::text))) WHERE ((cd_readings_channel_as_columns_by_service_point.service_point_id)::text = ("PVServicePointIDs".old_house_service_point_id)::text) GROUP BY cd_readings_channel_as_columns_by_service_point.service_point_id, date_trunc('month'::text, cd_readings_channel_as_columns_by_service_point.end_time);


ALTER TABLE public.monthly_energy_summary_houses_with_pv OWNER TO eileen;

--
-- Name: name_address_service_point_id; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW name_address_service_point_id AS
    SELECT "LocationRecords".cust_name, "LocationRecords".service_point_util_id, "LocationRecords".address1, "LocationRecords".address2 FROM "LocationRecords";


ALTER TABLE public.name_address_service_point_id OWNER TO eileen;

--
-- Name: power_meter_events_with_spid; Type: VIEW; Schema: public; Owner: dave
--

CREATE VIEW power_meter_events_with_spid AS
    SELECT pme.dtype, mlh.service_point_id, pme.id AS event_id, pme.event_category, pme.el_epoch_num, pme.el_seq_num, pme.event_ack_status, pme.event_text, pme.event_time, pme.generic_col_1 AS trap_recorded_epoch, pme.generic_col_2 AS event_is_a_swell, pme.generic_col_3 AS voltage_at_measurement_time, pme.generic_col_4, pme.generic_col_5, pme.generic_col_6, pme.generic_col_7, pme.generic_col_8, pme.generic_col_9, pme.generic_col_10, pme.insert_ts, pme.job_id, pme.event_key, pme.nic_reboot_count, pme.seconds_since_reboot, pme.event_severity, pme.source_id, pme.update_ts, pme.updated_by_user, pme.event_ack_note FROM ("PowerMeterEvents" pme JOIN "MeterLocationHistory" mlh ON (((((mlh.mac_address)::text = substr(pme.event_text, 11, 23)) AND (mlh.installed <= pme.event_time)) AND CASE WHEN (mlh.uninstalled IS NULL) THEN true ELSE (pme.event_time < mlh.uninstalled) END)));


ALTER TABLE public.power_meter_events_with_spid OWNER TO dave;

--
-- Name: pv_backup; Type: TABLE; Schema: public; Owner: dave; Tablespace: 
--

CREATE TABLE pv_backup (
    old_pv_service_point_id character varying,
    old_house_service_point_id character varying,
    "PV_Mod_size_kW" double precision,
    inverter_model character varying,
    "size_kW" real,
    "system_cap_kW" real,
    bat character varying,
    sub character varying,
    circuit smallint,
    date_uploaded timestamp without time zone,
    has_meter smallint,
    has_separate_pv_meter smallint,
    "add_cap_kW" real,
    upgraded_total_kw real,
    street character varying,
    city character varying,
    state character varying,
    zip integer,
    month_installed integer,
    year_installed integer,
    notes character varying,
    pv_service_point_id character varying,
    house_service_point_id character varying,
    new_spid character varying(50),
    new_spid_pv character varying(50)
);


ALTER TABLE public.pv_backup OWNER TO dave;

--
-- Name: pv_service_points_specifications_view; Type: VIEW; Schema: public; Owner: eileen
--

CREATE VIEW pv_service_points_specifications_view AS
    SELECT "PVServicePointIDs".old_pv_service_point_id AS pv_service_point_id, "PVServicePointIDs".old_house_service_point_id AS house_service_point_id, "PVServicePointIDs"."PV_Mod_size_kW", "PVServicePointIDs".inverter_model, "PVServicePointIDs"."size_kW", "PVServicePointIDs"."system_cap_kW", "PVServicePointIDs".bat, "PVServicePointIDs".sub, "PVServicePointIDs".circuit, "PVServicePointIDs".has_meter, "PVServicePointIDs".has_separate_pv_meter, "PVServicePointIDs"."add_cap_kW", "PVServicePointIDs".upgraded_total_kw, "PVServicePointIDs".street, "PVServicePointIDs".city, "PVServicePointIDs".state, "PVServicePointIDs".zip FROM "PVServicePointIDs" WHERE (("PVServicePointIDs".has_meter = 1) OR ("PVServicePointIDs".has_separate_pv_meter = 1));


ALTER TABLE public.pv_service_points_specifications_view OWNER TO eileen;

--
-- Name: raw_meter_readings; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW raw_meter_readings AS
    SELECT "Interval".end_time, "MeterData".meter_name, "Reading".channel, "Reading".raw_value, "Reading".value, "Reading".uom, "MeterData".util_device_id FROM ((("MeterData" JOIN "IntervalReadData" ON (("MeterData".meter_data_id = "IntervalReadData".meter_data_id))) JOIN "Interval" ON (("IntervalReadData".interval_read_data_id = "Interval".interval_read_data_id))) JOIN "Reading" ON (("Interval".interval_id = "Reading".interval_id))) ORDER BY "Interval".end_time, "MeterData".meter_name, "Reading".channel;


ALTER TABLE public.raw_meter_readings OWNER TO postgres;

--
-- Name: reading_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE reading_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reading_id_seq OWNER TO sepgroup;

--
-- Name: reading_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE reading_id_seq OWNED BY "Reading".reading_id;


--
-- Name: readings_not_referenced_by_mlh; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW readings_not_referenced_by_mlh AS
    SELECT readings_by_meter_location_history_new_spid_2.meter_name AS mlh_meter_name, readings_with_meter_data_id_unfiltered.meter_name AS full_meter_name, readings_by_meter_location_history_new_spid_2.channel AS mlh_channel, readings_by_meter_location_history_new_spid_2.value AS mlh_value, readings_with_meter_data_id_unfiltered.channel AS full_channel, readings_with_meter_data_id_unfiltered.value AS full_value, readings_by_meter_location_history_new_spid_2.end_time AS mlh_end_time, readings_with_meter_data_id_unfiltered.end_time AS full_end_time, readings_with_meter_data_id_unfiltered.meter_data_id AS full_meter_data_id FROM (readings_unfiltered readings_with_meter_data_id_unfiltered LEFT JOIN readings_by_meter_location_history readings_by_meter_location_history_new_spid_2 ON ((readings_with_meter_data_id_unfiltered.meter_data_id = readings_by_meter_location_history_new_spid_2.meter_data_id))) WHERE (readings_by_meter_location_history_new_spid_2.meter_data_id IS NULL);


ALTER TABLE public.readings_not_referenced_by_mlh OWNER TO postgres;

--
-- Name: VIEW readings_not_referenced_by_mlh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW readings_not_referenced_by_mlh IS 'Readings that are present in the DB but are not referenced by the Meter Location History. @author Daniel Zhang (張道博)';


--
-- Name: readings_with_pv_service_point_id; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW readings_with_pv_service_point_id AS
    SELECT readings_by_meter_location_history_new_spid.meter_name, readings_by_meter_location_history_new_spid.end_time, max((readings_by_meter_location_history_new_spid.location)::text) AS location_id, max(("PVServicePointIDs".old_pv_service_point_id)::text) AS pv_service_point_id, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (1)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS pv_channel_1, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (2)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS pv_channel_2, max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (3)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END) AS pv_channel_3, zero_to_null(max(CASE WHEN (readings_by_meter_location_history_new_spid.channel = (4)::smallint) THEN readings_by_meter_location_history_new_spid.value ELSE NULL::real END)) AS pv_channel_4_voltage FROM ("PVServicePointIDs" JOIN readings_by_meter_location_history readings_by_meter_location_history_new_spid ON ((("PVServicePointIDs".old_pv_service_point_id)::text = (readings_by_meter_location_history_new_spid.service_point_id)::text))) GROUP BY readings_by_meter_location_history_new_spid.meter_name, readings_by_meter_location_history_new_spid.end_time;


ALTER TABLE public.readings_with_pv_service_point_id OWNER TO postgres;

--
-- Name: VIEW readings_with_pv_service_point_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW readings_with_pv_service_point_id IS 'Readings that have an associated PV Service Point ID. @author Daniel Zhang (張道博)';


--
-- Name: register_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE register_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.register_id_seq OWNER TO sepgroup;

--
-- Name: register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE register_id_seq OWNED BY "Register".register_id;


--
-- Name: registerdata_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE registerdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.registerdata_id_seq OWNER TO sepgroup;

--
-- Name: registerdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE registerdata_id_seq OWNED BY "RegisterData".register_data_id;


--
-- Name: registerread_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE registerread_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.registerread_id_seq OWNER TO sepgroup;

--
-- Name: registerread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE registerread_id_seq OWNED BY "RegisterRead".register_read_id;


--
-- Name: registers; Type: VIEW; Schema: public; Owner: daniel
--

CREATE VIEW registers AS
    SELECT "Register".number, "MeterData".meter_name, "RegisterRead".read_time FROM (((("MeterData" JOIN "RegisterData" ON (("MeterData".meter_data_id = "RegisterData".meter_data_id))) JOIN "RegisterRead" ON (("RegisterData".register_data_id = "RegisterRead".register_data_id))) JOIN "Tier" ON (("RegisterRead".register_read_id = "Tier".register_read_id))) JOIN "Register" ON (("Tier".tier_id = "Register".tier_id)));


ALTER TABLE public.registers OWNER TO daniel;

--
-- Name: VIEW registers; Type: COMMENT; Schema: public; Owner: daniel
--

COMMENT ON VIEW registers IS 'This is being used for development. @author Daniel Zhang (張道博)';


--
-- Name: test_AverageFifteenMinKiheiSCADATemperatureHumidity; Type: TABLE; Schema: public; Owner: daniel; Tablespace: 
--

CREATE TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" (
    "timestamp" timestamp without time zone NOT NULL,
    met_air_temp_degf double precision,
    met_rel_humid_pct double precision
);


ALTER TABLE public."test_AverageFifteenMinKiheiSCADATemperatureHumidity" OWNER TO daniel;

--
-- Name: tier_id_seq; Type: SEQUENCE; Schema: public; Owner: sepgroup
--

CREATE SEQUENCE tier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tier_id_seq OWNER TO sepgroup;

--
-- Name: tier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sepgroup
--

ALTER SEQUENCE tier_id_seq OWNED BY "Tier".tier_id;


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Event" ALTER COLUMN event_id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: event_data_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "EventData" ALTER COLUMN event_data_id SET DEFAULT nextval('event_data_id_seq'::regclass);


--
-- Name: interval_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Interval" ALTER COLUMN interval_id SET DEFAULT nextval('interval_id_seq'::regclass);


--
-- Name: interval_read_data_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "IntervalReadData" ALTER COLUMN interval_read_data_id SET DEFAULT nextval('intervalreaddata_id_seq'::regclass);


--
-- Name: meter_data_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "MeterData" ALTER COLUMN meter_data_id SET DEFAULT nextval('meterdata_id_seq'::regclass);


--
-- Name: reading_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Reading" ALTER COLUMN reading_id SET DEFAULT nextval('reading_id_seq'::regclass);


--
-- Name: register_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Register" ALTER COLUMN register_id SET DEFAULT nextval('register_id_seq'::regclass);


--
-- Name: register_data_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "RegisterData" ALTER COLUMN register_data_id SET DEFAULT nextval('registerdata_id_seq'::regclass);


--
-- Name: register_read_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "RegisterRead" ALTER COLUMN register_read_id SET DEFAULT nextval('registerread_id_seq'::regclass);


--
-- Name: tier_id; Type: DEFAULT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Tier" ALTER COLUMN tier_id SET DEFAULT nextval('tier_id_seq'::regclass);


--
-- Name: AverageFifteenMinKiheiSCADATemperatureHumidity_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: daniel; Tablespace: 
--

ALTER TABLE ONLY "test_AverageFifteenMinKiheiSCADATemperatureHumidity"
    ADD CONSTRAINT "AverageFifteenMinKiheiSCADATemperatureHumidity_copy_pkey" PRIMARY KEY ("timestamp");


--
-- Name: CircuitData_pkey1; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "CircuitData"
    ADD CONSTRAINT "CircuitData_pkey1" PRIMARY KEY (circuit, "timestamp");


--
-- Name: EgaugeEnergyAutoload_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "EgaugeEnergyAutoload"
    ADD CONSTRAINT "EgaugeEnergyAutoload_pkey" PRIMARY KEY (egauge_id, datetime);


--
-- Name: EventData_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "EventData"
    ADD CONSTRAINT "EventData_pkey" PRIMARY KEY (event_data_id);


--
-- Name: Event_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "Event"
    ADD CONSTRAINT "Event_pkey" PRIMARY KEY (event_id);


--
-- Name: IntervalReadData_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "IntervalReadData"
    ADD CONSTRAINT "IntervalReadData_pkey" PRIMARY KEY (interval_read_data_id);


--
-- Name: Interval_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "Interval"
    ADD CONSTRAINT "Interval_pkey" PRIMARY KEY (interval_id);


--
-- Name: IrradianceData_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "AverageFifteenMinIrradianceData"
    ADD CONSTRAINT "IrradianceData_copy_pkey" PRIMARY KEY (sensor_id, "timestamp");


--
-- Name: KiheiSCADATemperatureHumidity_copy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "AverageFifteenMinKiheiSCADATemperatureHumidity"
    ADD CONSTRAINT "KiheiSCADATemperatureHumidity_copy_pkey" PRIMARY KEY ("timestamp");


--
-- Name: KiheiSCADATemperatureHumidity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "KiheiSCADATemperatureHumidity"
    ADD CONSTRAINT "KiheiSCADATemperatureHumidity_pkey" PRIMARY KEY ("timestamp");


--
-- Name: LocationRecords_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "LocationRecords"
    ADD CONSTRAINT "LocationRecords_pkey" PRIMARY KEY (device_util_id);


--
-- Name: MeterLocationHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "MeterLocationHistory"
    ADD CONSTRAINT "MeterLocationHistory_pkey" PRIMARY KEY (meter_name, installed);


--
-- Name: MeterRecords_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "MeterRecords"
    ADD CONSTRAINT "MeterRecords_pkey" PRIMARY KEY (device_util_id);


--
-- Name: NotificationHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "NotificationHistory"
    ADD CONSTRAINT "NotificationHistory_pkey" PRIMARY KEY ("notificationType", "notificationTime");


--
-- Name: PowerMeterEvents_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "PowerMeterEvents"
    ADD CONSTRAINT "PowerMeterEvents_pkey" PRIMARY KEY (id, event_time);


--
-- Name: Reading_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "Reading"
    ADD CONSTRAINT "Reading_pkey" PRIMARY KEY (reading_id);


--
-- Name: RegisterData_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "RegisterData"
    ADD CONSTRAINT "RegisterData_pkey" PRIMARY KEY (register_data_id);


--
-- Name: RegisterRead_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "RegisterRead"
    ADD CONSTRAINT "RegisterRead_pkey" PRIMARY KEY (register_read_id);


--
-- Name: Register_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "Register"
    ADD CONSTRAINT "Register_pkey" PRIMARY KEY (register_id);


--
-- Name: Tier_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "Tier"
    ADD CONSTRAINT "Tier_pkey" PRIMARY KEY (tier_id);


--
-- Name: TransformerData_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "TransformerData"
    ADD CONSTRAINT "TransformerData_pkey" PRIMARY KEY (transformer, "timestamp");


--
-- Name: WeatherNOAA_pkey; Type: CONSTRAINT; Schema: public; Owner: daniel; Tablespace: 
--

ALTER TABLE ONLY "WeatherNOAA"
    ADD CONSTRAINT "WeatherNOAA_pkey" PRIMARY KEY (wban, datetime, record_type);


--
-- Name: firstkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "AsBuilt"
    ADD CONSTRAINT firstkey PRIMARY KEY (spid);


--
-- Name: irrad_sensor_info_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "IrradianceSensorInfo"
    ADD CONSTRAINT irrad_sensor_info_pkey PRIMARY KEY (sensor_id);


--
-- Name: irradiance_data_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "IrradianceData"
    ADD CONSTRAINT irradiance_data_pkey PRIMARY KEY (sensor_id, "timestamp");


--
-- Name: meter_data_pkey; Type: CONSTRAINT; Schema: public; Owner: sepgroup; Tablespace: 
--

ALTER TABLE ONLY "MeterData"
    ADD CONSTRAINT meter_data_pkey PRIMARY KEY (meter_data_id);


--
-- Name: EventData_event_data_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "EventData_event_data_id_key" ON "EventData" USING btree (event_data_id);


--
-- Name: IntervalReadData_interval_read_data_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "IntervalReadData_interval_read_data_id_key" ON "IntervalReadData" USING btree (interval_read_data_id);


--
-- Name: Interval_end_time_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "Interval_end_time_idx" ON "Interval" USING btree (end_time);


--
-- Name: Interval_interval_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "Interval_interval_id_key" ON "Interval" USING btree (interval_id);


--
-- Name: MeterData_meter_data_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "MeterData_meter_data_id_key" ON "MeterData" USING btree (meter_data_id);


--
-- Name: MeterData_meter_name_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "MeterData_meter_name_idx" ON "MeterData" USING btree (meter_name);


--
-- Name: RegisterData_meter_data_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "RegisterData_meter_data_id_idx" ON "RegisterData" USING btree (meter_data_id);


--
-- Name: RegisterData_register_data_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "RegisterData_register_data_id_key" ON "RegisterData" USING btree (register_data_id);


--
-- Name: RegisterRead_register_data_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "RegisterRead_register_data_id_idx" ON "RegisterRead" USING btree (register_data_id);


--
-- Name: RegisterRead_register_read_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "RegisterRead_register_read_id_key" ON "RegisterRead" USING btree (register_read_id);


--
-- Name: Register_register_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "Register_register_id_idx" ON "Register" USING btree (register_id);


--
-- Name: Register_tier_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "Register_tier_id_idx" ON "Register" USING btree (tier_id);


--
-- Name: Tier_register_read_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX "Tier_register_read_id_idx" ON "Tier" USING btree (register_read_id);


--
-- Name: Tier_tier_id_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX "Tier_tier_id_key" ON "Tier" USING btree (tier_id);


--
-- Name: device_util_id_index; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX device_util_id_index ON "LocationRecords" USING btree (device_util_id);


--
-- Name: idx_primary_key; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX idx_primary_key ON "EgaugeEnergyAutoload" USING btree (egauge_id, datetime);


--
-- Name: installed_uninstalled_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX installed_uninstalled_idx ON "MeterLocationHistory" USING btree (installed, uninstalled);


--
-- Name: interval_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX interval_id_idx ON "Reading" USING btree (interval_id);


--
-- Name: interval_read_data_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX interval_read_data_id_idx ON "Interval" USING btree (interval_read_data_id);


--
-- Name: mac_address_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX mac_address_idx ON "MeterLocationHistory" USING btree (mac_address);


--
-- Name: meter_data_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX meter_data_id_idx ON "IntervalReadData" USING btree (meter_data_id);


--
-- Name: old_service_point_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX old_service_point_id_idx ON "MeterLocationHistory" USING btree (old_service_point_id);


--
-- Name: reading_channel_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX reading_channel_idx ON "Reading" USING btree (channel);


--
-- Name: reading_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE UNIQUE INDEX reading_id_idx ON "Reading" USING btree (reading_id);


--
-- Name: service_point_id_idx; Type: INDEX; Schema: public; Owner: sepgroup; Tablespace: 
--

CREATE INDEX service_point_id_idx ON "MeterLocationHistory" USING btree (service_point_id);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: eileen
--

CREATE RULE "_RETURN" AS ON SELECT TO dates_irradiance_data DO INSTEAD SELECT "IrradianceSensorInfo".sensor_id, "IrradianceSensorInfo".latitude, "IrradianceSensorInfo".longitude, count("IrradianceData".irradiance_w_per_m2) AS count, min("IrradianceData"."timestamp") AS "Earliest Date", max("IrradianceData"."timestamp") AS "Latest Date", "IrradianceSensorInfo".name FROM ("IrradianceData" JOIN "IrradianceSensorInfo" ON (("IrradianceSensorInfo".sensor_id = "IrradianceData".sensor_id))) GROUP BY "IrradianceSensorInfo".sensor_id, "IrradianceSensorInfo".latitude, "IrradianceSensorInfo".longitude;


--
-- Name: EventData_meter_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "EventData"
    ADD CONSTRAINT "EventData_meter_data_id_fkey" FOREIGN KEY (meter_data_id) REFERENCES "MeterData"(meter_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Event"
    ADD CONSTRAINT "Event_event_id_fkey" FOREIGN KEY (event_data_id) REFERENCES "EventData"(event_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: IntervalReadData_meter_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "IntervalReadData"
    ADD CONSTRAINT "IntervalReadData_meter_data_id_fkey" FOREIGN KEY (meter_data_id) REFERENCES "MeterData"(meter_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Interval_interval_read_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Interval"
    ADD CONSTRAINT "Interval_interval_read_data_id_fkey" FOREIGN KEY (interval_read_data_id) REFERENCES "IntervalReadData"(interval_read_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Reading_interval_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Reading"
    ADD CONSTRAINT "Reading_interval_id_fkey" FOREIGN KEY (interval_id) REFERENCES "Interval"(interval_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RegisterData_meter_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "RegisterData"
    ADD CONSTRAINT "RegisterData_meter_data_id_fkey" FOREIGN KEY (meter_data_id) REFERENCES "MeterData"(meter_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: RegisterRead_register_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "RegisterRead"
    ADD CONSTRAINT "RegisterRead_register_data_id_fkey" FOREIGN KEY (register_data_id) REFERENCES "RegisterData"(register_data_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Register_register_read_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Register"
    ADD CONSTRAINT "Register_register_read_id_fkey" FOREIGN KEY (tier_id) REFERENCES "Tier"(tier_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Tier_register_read_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sepgroup
--

ALTER TABLE ONLY "Tier"
    ADD CONSTRAINT "Tier_register_read_id_fkey" FOREIGN KEY (register_read_id) REFERENCES "RegisterRead"(register_read_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: zero_to_null(real); Type: ACL; Schema: public; Owner: daniel
--

REVOKE ALL ON FUNCTION zero_to_null(real) FROM PUBLIC;
REVOKE ALL ON FUNCTION zero_to_null(real) FROM daniel;
GRANT ALL ON FUNCTION zero_to_null(real) TO daniel;
GRANT ALL ON FUNCTION zero_to_null(real) TO PUBLIC;
GRANT ALL ON FUNCTION zero_to_null(real) TO sepgroup;
GRANT ALL ON FUNCTION zero_to_null(real) TO sepgroupreadonly;


--
-- Name: zero_to_null(double precision); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION zero_to_null(double precision) FROM PUBLIC;
REVOKE ALL ON FUNCTION zero_to_null(double precision) FROM postgres;
GRANT ALL ON FUNCTION zero_to_null(double precision) TO postgres;
GRANT ALL ON FUNCTION zero_to_null(double precision) TO PUBLIC;
GRANT ALL ON FUNCTION zero_to_null(double precision) TO sepgroup;
GRANT ALL ON FUNCTION zero_to_null(double precision) TO sepgroup_nonmsg;
GRANT ALL ON FUNCTION zero_to_null(double precision) TO sepgroupreadonly;


--
-- Name: Event; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "Event" FROM PUBLIC;
REVOKE ALL ON TABLE "Event" FROM sepgroup;
GRANT ALL ON TABLE "Event" TO sepgroup;
GRANT SELECT ON TABLE "Event" TO sepgroupreadonly;


--
-- Name: EventData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "EventData" FROM PUBLIC;
REVOKE ALL ON TABLE "EventData" FROM sepgroup;
GRANT ALL ON TABLE "EventData" TO sepgroup;
GRANT SELECT ON TABLE "EventData" TO sepgroupreadonly;


--
-- Name: MeterData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "MeterData" FROM PUBLIC;
REVOKE ALL ON TABLE "MeterData" FROM sepgroup;
GRANT ALL ON TABLE "MeterData" TO sepgroup;
GRANT SELECT ON TABLE "MeterData" TO sepgroupreadonly;


SET search_path = dz, pg_catalog;

--
-- Name: count_of_event_duplicates; Type: ACL; Schema: dz; Owner: daniel
--

REVOKE ALL ON TABLE count_of_event_duplicates FROM PUBLIC;
REVOKE ALL ON TABLE count_of_event_duplicates FROM daniel;
GRANT ALL ON TABLE count_of_event_duplicates TO daniel;
GRANT ALL ON TABLE count_of_event_duplicates TO sepgroup;
GRANT SELECT ON TABLE count_of_event_duplicates TO sepgroupreadonly;


SET search_path = public, pg_catalog;

--
-- Name: Interval; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "Interval" FROM PUBLIC;
REVOKE ALL ON TABLE "Interval" FROM sepgroup;
GRANT ALL ON TABLE "Interval" TO sepgroup;
GRANT SELECT ON TABLE "Interval" TO sepgroupreadonly;


--
-- Name: IntervalReadData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "IntervalReadData" FROM PUBLIC;
REVOKE ALL ON TABLE "IntervalReadData" FROM sepgroup;
GRANT ALL ON TABLE "IntervalReadData" TO sepgroup;
GRANT SELECT ON TABLE "IntervalReadData" TO sepgroupreadonly;


--
-- Name: MeterLocationHistory; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "MeterLocationHistory" FROM PUBLIC;
REVOKE ALL ON TABLE "MeterLocationHistory" FROM sepgroup;
GRANT ALL ON TABLE "MeterLocationHistory" TO sepgroup;
GRANT SELECT ON TABLE "MeterLocationHistory" TO sepgroupreadonly;


--
-- Name: Reading; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "Reading" FROM PUBLIC;
REVOKE ALL ON TABLE "Reading" FROM sepgroup;
GRANT ALL ON TABLE "Reading" TO sepgroup;
GRANT SELECT ON TABLE "Reading" TO sepgroupreadonly;


SET search_path = dz, pg_catalog;

--
-- Name: readings_by_meter_location_history; Type: ACL; Schema: dz; Owner: daniel
--

REVOKE ALL ON TABLE readings_by_meter_location_history FROM PUBLIC;
REVOKE ALL ON TABLE readings_by_meter_location_history FROM daniel;
GRANT ALL ON TABLE readings_by_meter_location_history TO daniel;
GRANT ALL ON TABLE readings_by_meter_location_history TO sepgroup;
GRANT SELECT ON TABLE readings_by_meter_location_history TO sepgroupreadonly;


--
-- Name: deprecated_readings_by_mlh_transposed_columns_opt1; Type: ACL; Schema: dz; Owner: daniel
--

REVOKE ALL ON TABLE deprecated_readings_by_mlh_transposed_columns_opt1 FROM PUBLIC;
REVOKE ALL ON TABLE deprecated_readings_by_mlh_transposed_columns_opt1 FROM daniel;
GRANT ALL ON TABLE deprecated_readings_by_mlh_transposed_columns_opt1 TO daniel;
GRANT ALL ON TABLE deprecated_readings_by_mlh_transposed_columns_opt1 TO sepgroup;
GRANT SELECT ON TABLE deprecated_readings_by_mlh_transposed_columns_opt1 TO sepgroupreadonly;


--
-- Name: readings_by_mlh_new_spid_for_ashkan_from_2013-07-01; Type: ACL; Schema: dz; Owner: daniel
--

REVOKE ALL ON TABLE "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" FROM PUBLIC;
REVOKE ALL ON TABLE "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" FROM daniel;
GRANT ALL ON TABLE "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" TO daniel;
GRANT ALL ON TABLE "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" TO sepgroup;
GRANT SELECT ON TABLE "readings_by_mlh_new_spid_for_ashkan_from_2013-07-01" TO sepgroupreadonly;


--
-- Name: readings_unfiltered; Type: ACL; Schema: dz; Owner: daniel
--

REVOKE ALL ON TABLE readings_unfiltered FROM PUBLIC;
REVOKE ALL ON TABLE readings_unfiltered FROM daniel;
GRANT ALL ON TABLE readings_unfiltered TO daniel;
GRANT ALL ON TABLE readings_unfiltered TO sepgroup;
GRANT SELECT ON TABLE readings_unfiltered TO sepgroupreadonly;


SET search_path = public, pg_catalog;

--
-- Name: AsBuilt; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "AsBuilt" FROM PUBLIC;
REVOKE ALL ON TABLE "AsBuilt" FROM sepgroup;
GRANT ALL ON TABLE "AsBuilt" TO sepgroup;
GRANT SELECT ON TABLE "AsBuilt" TO sepgroupreadonly;


--
-- Name: AverageFifteenMinIrradianceData; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE "AverageFifteenMinIrradianceData" FROM PUBLIC;
REVOKE ALL ON TABLE "AverageFifteenMinIrradianceData" FROM postgres;
GRANT ALL ON TABLE "AverageFifteenMinIrradianceData" TO postgres;
GRANT ALL ON TABLE "AverageFifteenMinIrradianceData" TO sepgroup;
GRANT SELECT ON TABLE "AverageFifteenMinIrradianceData" TO sepgroupreadonly;


--
-- Name: AverageFifteenMinKiheiSCADATemperatureHumidity; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" FROM PUBLIC;
REVOKE ALL ON TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" FROM postgres;
GRANT ALL ON TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" TO postgres;
GRANT ALL ON TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" TO sepgroup;
GRANT SELECT ON TABLE "AverageFifteenMinKiheiSCADATemperatureHumidity" TO sepgroupreadonly;


--
-- Name: BatteryWailea; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "BatteryWailea" FROM PUBLIC;
REVOKE ALL ON TABLE "BatteryWailea" FROM sepgroup;
GRANT ALL ON TABLE "BatteryWailea" TO sepgroup;
GRANT SELECT ON TABLE "BatteryWailea" TO sepgroupreadonly;


--
-- Name: CircuitData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "CircuitData" FROM PUBLIC;
REVOKE ALL ON TABLE "CircuitData" FROM sepgroup;
GRANT ALL ON TABLE "CircuitData" TO sepgroup;
GRANT SELECT ON TABLE "CircuitData" TO sepgroupreadonly;


--
-- Name: CircuitDataCopy; Type: ACL; Schema: public; Owner: dave
--

REVOKE ALL ON TABLE "CircuitDataCopy" FROM PUBLIC;
REVOKE ALL ON TABLE "CircuitDataCopy" FROM dave;
GRANT ALL ON TABLE "CircuitDataCopy" TO dave;
GRANT ALL ON TABLE "CircuitDataCopy" TO sepgroup;
GRANT SELECT ON TABLE "CircuitDataCopy" TO sepgroupreadonly;


--
-- Name: EgaugeEnergyAutoload; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "EgaugeEnergyAutoload" FROM PUBLIC;
REVOKE ALL ON TABLE "EgaugeEnergyAutoload" FROM sepgroup;
GRANT ALL ON TABLE "EgaugeEnergyAutoload" TO sepgroup;
GRANT SELECT ON TABLE "EgaugeEnergyAutoload" TO sepgroupreadonly;


--
-- Name: EgaugeInfo; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE "EgaugeInfo" FROM PUBLIC;
REVOKE ALL ON TABLE "EgaugeInfo" FROM eileen;
GRANT ALL ON TABLE "EgaugeInfo" TO eileen;
GRANT ALL ON TABLE "EgaugeInfo" TO sepgroup;
GRANT SELECT ON TABLE "EgaugeInfo" TO sepgroupreadonly;


--
-- Name: IrradianceData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "IrradianceData" FROM PUBLIC;
REVOKE ALL ON TABLE "IrradianceData" FROM sepgroup;
GRANT ALL ON TABLE "IrradianceData" TO sepgroup;
GRANT SELECT ON TABLE "IrradianceData" TO sepgroupreadonly;


--
-- Name: IrradianceSensorInfo; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "IrradianceSensorInfo" FROM PUBLIC;
REVOKE ALL ON TABLE "IrradianceSensorInfo" FROM sepgroup;
GRANT ALL ON TABLE "IrradianceSensorInfo" TO sepgroup;
GRANT SELECT ON TABLE "IrradianceSensorInfo" TO sepgroupreadonly;


--
-- Name: KiheiSCADATemperatureHumidity; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE "KiheiSCADATemperatureHumidity" FROM PUBLIC;
REVOKE ALL ON TABLE "KiheiSCADATemperatureHumidity" FROM postgres;
GRANT ALL ON TABLE "KiheiSCADATemperatureHumidity" TO postgres;
GRANT ALL ON TABLE "KiheiSCADATemperatureHumidity" TO sepgroup;
GRANT SELECT ON TABLE "KiheiSCADATemperatureHumidity" TO sepgroupreadonly;


--
-- Name: LocationRecords; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "LocationRecords" FROM PUBLIC;
REVOKE ALL ON TABLE "LocationRecords" FROM sepgroup;
GRANT ALL ON TABLE "LocationRecords" TO sepgroup;
GRANT SELECT ON TABLE "LocationRecords" TO sepgroupreadonly;


--
-- Name: MSG_PV_Data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE "MSG_PV_Data" FROM PUBLIC;
REVOKE ALL ON TABLE "MSG_PV_Data" FROM eileen;
GRANT ALL ON TABLE "MSG_PV_Data" TO eileen;
GRANT ALL ON TABLE "MSG_PV_Data" TO sepgroup;
GRANT SELECT ON TABLE "MSG_PV_Data" TO sepgroupreadonly;


--
-- Name: MeterRecords; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "MeterRecords" FROM PUBLIC;
REVOKE ALL ON TABLE "MeterRecords" FROM sepgroup;
GRANT ALL ON TABLE "MeterRecords" TO sepgroup;
GRANT SELECT ON TABLE "MeterRecords" TO sepgroupreadonly;


--
-- Name: NotificationHistory; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE "NotificationHistory" FROM PUBLIC;
REVOKE ALL ON TABLE "NotificationHistory" FROM postgres;
GRANT ALL ON TABLE "NotificationHistory" TO postgres;
GRANT ALL ON TABLE "NotificationHistory" TO sepgroup;
GRANT SELECT ON TABLE "NotificationHistory" TO sepgroupreadonly;


--
-- Name: PVServicePointIDs; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "PVServicePointIDs" FROM PUBLIC;
REVOKE ALL ON TABLE "PVServicePointIDs" FROM sepgroup;
GRANT ALL ON TABLE "PVServicePointIDs" TO sepgroup;
GRANT SELECT ON TABLE "PVServicePointIDs" TO sepgroupreadonly;


--
-- Name: PowerMeterEvents; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "PowerMeterEvents" FROM PUBLIC;
REVOKE ALL ON TABLE "PowerMeterEvents" FROM sepgroup;
GRANT ALL ON TABLE "PowerMeterEvents" TO sepgroup;
GRANT SELECT ON TABLE "PowerMeterEvents" TO sepgroupreadonly;


--
-- Name: Register; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "Register" FROM PUBLIC;
REVOKE ALL ON TABLE "Register" FROM sepgroup;
GRANT ALL ON TABLE "Register" TO sepgroup;
GRANT SELECT ON TABLE "Register" TO sepgroupreadonly;


--
-- Name: RegisterData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "RegisterData" FROM PUBLIC;
REVOKE ALL ON TABLE "RegisterData" FROM sepgroup;
GRANT ALL ON TABLE "RegisterData" TO sepgroup;
GRANT SELECT ON TABLE "RegisterData" TO sepgroupreadonly;


--
-- Name: RegisterRead; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "RegisterRead" FROM PUBLIC;
REVOKE ALL ON TABLE "RegisterRead" FROM sepgroup;
GRANT ALL ON TABLE "RegisterRead" TO sepgroup;
GRANT SELECT ON TABLE "RegisterRead" TO sepgroupreadonly;


--
-- Name: TapData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "TapData" FROM PUBLIC;
REVOKE ALL ON TABLE "TapData" FROM sepgroup;
GRANT ALL ON TABLE "TapData" TO sepgroup;
GRANT SELECT ON TABLE "TapData" TO sepgroupreadonly;


--
-- Name: Tier; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "Tier" FROM PUBLIC;
REVOKE ALL ON TABLE "Tier" FROM sepgroup;
GRANT ALL ON TABLE "Tier" TO sepgroup;
GRANT SELECT ON TABLE "Tier" TO sepgroupreadonly;


--
-- Name: TransformerData; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON TABLE "TransformerData" FROM PUBLIC;
REVOKE ALL ON TABLE "TransformerData" FROM sepgroup;
GRANT ALL ON TABLE "TransformerData" TO sepgroup;
GRANT SELECT ON TABLE "TransformerData" TO sepgroupreadonly;


--
-- Name: WeatherNOAA; Type: ACL; Schema: public; Owner: daniel
--

REVOKE ALL ON TABLE "WeatherNOAA" FROM PUBLIC;
REVOKE ALL ON TABLE "WeatherNOAA" FROM daniel;
GRANT ALL ON TABLE "WeatherNOAA" TO daniel;
GRANT ALL ON TABLE "WeatherNOAA" TO sepgroup;
GRANT SELECT ON TABLE "WeatherNOAA" TO sepgroupreadonly;


--
-- Name: _IrradianceFifteenMinIntervals; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE "_IrradianceFifteenMinIntervals" FROM PUBLIC;
REVOKE ALL ON TABLE "_IrradianceFifteenMinIntervals" FROM postgres;
GRANT ALL ON TABLE "_IrradianceFifteenMinIntervals" TO postgres;
GRANT ALL ON TABLE "_IrradianceFifteenMinIntervals" TO sepgroup;
GRANT SELECT ON TABLE "_IrradianceFifteenMinIntervals" TO sepgroupreadonly;


--
-- Name: az_ashkan1; Type: ACL; Schema: public; Owner: christian
--

REVOKE ALL ON TABLE az_ashkan1 FROM PUBLIC;
REVOKE ALL ON TABLE az_ashkan1 FROM christian;
GRANT ALL ON TABLE az_ashkan1 TO christian;
GRANT ALL ON TABLE az_ashkan1 TO sepgroup;
GRANT SELECT ON TABLE az_ashkan1 TO sepgroupreadonly;


--
-- Name: az_houses_all_with_smart_meter; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_houses_all_with_smart_meter FROM PUBLIC;
REVOKE ALL ON TABLE az_houses_all_with_smart_meter FROM eileen;
GRANT ALL ON TABLE az_houses_all_with_smart_meter TO eileen;
GRANT ALL ON TABLE az_houses_all_with_smart_meter TO sepgroup;
GRANT SELECT ON TABLE az_houses_all_with_smart_meter TO sepgroupreadonly;


--
-- Name: az_houses_with_no_pv; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_houses_with_no_pv FROM PUBLIC;
REVOKE ALL ON TABLE az_houses_with_no_pv FROM eileen;
GRANT ALL ON TABLE az_houses_with_no_pv TO eileen;
GRANT ALL ON TABLE az_houses_with_no_pv TO sepgroup;
GRANT SELECT ON TABLE az_houses_with_no_pv TO sepgroupreadonly;


--
-- Name: az_houses_with_pv_and_pv_meter; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_houses_with_pv_and_pv_meter FROM PUBLIC;
REVOKE ALL ON TABLE az_houses_with_pv_and_pv_meter FROM eileen;
GRANT ALL ON TABLE az_houses_with_pv_and_pv_meter TO eileen;
GRANT ALL ON TABLE az_houses_with_pv_and_pv_meter TO sepgroup;
GRANT SELECT ON TABLE az_houses_with_pv_and_pv_meter TO sepgroupreadonly;


--
-- Name: az_houses_with_pv_no_extra_meter; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_houses_with_pv_no_extra_meter FROM PUBLIC;
REVOKE ALL ON TABLE az_houses_with_pv_no_extra_meter FROM eileen;
GRANT ALL ON TABLE az_houses_with_pv_no_extra_meter TO eileen;
GRANT ALL ON TABLE az_houses_with_pv_no_extra_meter TO sepgroup;
GRANT SELECT ON TABLE az_houses_with_pv_no_extra_meter TO sepgroupreadonly;


--
-- Name: az_noaa_weather_data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_noaa_weather_data FROM PUBLIC;
REVOKE ALL ON TABLE az_noaa_weather_data FROM eileen;
GRANT ALL ON TABLE az_noaa_weather_data TO eileen;
GRANT ALL ON TABLE az_noaa_weather_data TO sepgroup;
GRANT SELECT ON TABLE az_noaa_weather_data TO sepgroupreadonly;


--
-- Name: readings_by_meter_location_history; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE readings_by_meter_location_history FROM PUBLIC;
REVOKE ALL ON TABLE readings_by_meter_location_history FROM eileen;
GRANT ALL ON TABLE readings_by_meter_location_history TO eileen;
GRANT ALL ON TABLE readings_by_meter_location_history TO sepgroup;
GRANT SELECT ON TABLE readings_by_meter_location_history TO sepgroupreadonly;


--
-- Name: cd_readings_channel_as_columns_by_service_point; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE cd_readings_channel_as_columns_by_service_point FROM PUBLIC;
REVOKE ALL ON TABLE cd_readings_channel_as_columns_by_service_point FROM eileen;
GRANT ALL ON TABLE cd_readings_channel_as_columns_by_service_point TO eileen;
GRANT ALL ON TABLE cd_readings_channel_as_columns_by_service_point TO sepgroup;
GRANT SELECT ON TABLE cd_readings_channel_as_columns_by_service_point TO sepgroupreadonly;


--
-- Name: az_readings_channel_as_columns_by_spid; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_readings_channel_as_columns_by_spid FROM PUBLIC;
REVOKE ALL ON TABLE az_readings_channel_as_columns_by_spid FROM eileen;
GRANT ALL ON TABLE az_readings_channel_as_columns_by_spid TO eileen;
GRANT ALL ON TABLE az_readings_channel_as_columns_by_spid TO sepgroup;
GRANT SELECT ON TABLE az_readings_channel_as_columns_by_spid TO sepgroupreadonly;


--
-- Name: readings_channel_as_columns_by_new_spid; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE readings_channel_as_columns_by_new_spid FROM PUBLIC;
REVOKE ALL ON TABLE readings_channel_as_columns_by_new_spid FROM eileen;
GRANT ALL ON TABLE readings_channel_as_columns_by_new_spid TO eileen;
GRANT ALL ON TABLE readings_channel_as_columns_by_new_spid TO sepgroup;
GRANT SELECT ON TABLE readings_channel_as_columns_by_new_spid TO sepgroupreadonly;


--
-- Name: az_readings_channels_as_columns_new_spid; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE az_readings_channels_as_columns_new_spid FROM PUBLIC;
REVOKE ALL ON TABLE az_readings_channels_as_columns_new_spid FROM eileen;
GRANT ALL ON TABLE az_readings_channels_as_columns_new_spid TO eileen;
GRANT ALL ON TABLE az_readings_channels_as_columns_new_spid TO sepgroup;
GRANT SELECT ON TABLE az_readings_channels_as_columns_new_spid TO sepgroupreadonly;


--
-- Name: cd_20130706-20130711; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE "cd_20130706-20130711" FROM PUBLIC;
REVOKE ALL ON TABLE "cd_20130706-20130711" FROM eileen;
GRANT ALL ON TABLE "cd_20130706-20130711" TO eileen;
GRANT ALL ON TABLE "cd_20130706-20130711" TO sepgroup;
GRANT SELECT ON TABLE "cd_20130706-20130711" TO sepgroupreadonly;


--
-- Name: cd_20130709-20130710; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE "cd_20130709-20130710" FROM PUBLIC;
REVOKE ALL ON TABLE "cd_20130709-20130710" FROM eileen;
GRANT ALL ON TABLE "cd_20130709-20130710" TO eileen;
GRANT ALL ON TABLE "cd_20130709-20130710" TO sepgroup;
GRANT SELECT ON TABLE "cd_20130709-20130710" TO sepgroupreadonly;


--
-- Name: cd_meter_ids_for_houses_with_pv_with_locations; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE cd_meter_ids_for_houses_with_pv_with_locations FROM PUBLIC;
REVOKE ALL ON TABLE cd_meter_ids_for_houses_with_pv_with_locations FROM eileen;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE ON TABLE cd_meter_ids_for_houses_with_pv_with_locations TO eileen;
GRANT ALL ON TABLE cd_meter_ids_for_houses_with_pv_with_locations TO sepgroup;
GRANT SELECT ON TABLE cd_meter_ids_for_houses_with_pv_with_locations TO sepgroupreadonly;


--
-- Name: readings_unfiltered; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE readings_unfiltered FROM PUBLIC;
REVOKE ALL ON TABLE readings_unfiltered FROM postgres;
GRANT ALL ON TABLE readings_unfiltered TO postgres;
GRANT ALL ON TABLE readings_unfiltered TO sepgroup;
GRANT SELECT ON TABLE readings_unfiltered TO sepgroupreadonly;


--
-- Name: cd_energy_voltages_for_houses_with_pv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cd_energy_voltages_for_houses_with_pv FROM PUBLIC;
REVOKE ALL ON TABLE cd_energy_voltages_for_houses_with_pv FROM postgres;
GRANT ALL ON TABLE cd_energy_voltages_for_houses_with_pv TO postgres;
GRANT ALL ON TABLE cd_energy_voltages_for_houses_with_pv TO sepgroup;
GRANT SELECT ON TABLE cd_energy_voltages_for_houses_with_pv TO sepgroupreadonly;


--
-- Name: cd_houses_with_pv_no_pv_meter; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE cd_houses_with_pv_no_pv_meter FROM PUBLIC;
REVOKE ALL ON TABLE cd_houses_with_pv_no_pv_meter FROM eileen;
GRANT ALL ON TABLE cd_houses_with_pv_no_pv_meter TO eileen;
GRANT ALL ON TABLE cd_houses_with_pv_no_pv_meter TO sepgroup;
GRANT SELECT ON TABLE cd_houses_with_pv_no_pv_meter TO sepgroupreadonly;


--
-- Name: cd_monthly_summary; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE cd_monthly_summary FROM PUBLIC;
REVOKE ALL ON TABLE cd_monthly_summary FROM eileen;
GRANT ALL ON TABLE cd_monthly_summary TO eileen;
GRANT ALL ON TABLE cd_monthly_summary TO sepgroup;
GRANT SELECT ON TABLE cd_monthly_summary TO sepgroupreadonly;


--
-- Name: count_of_meters_not_in_mlh; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE count_of_meters_not_in_mlh FROM PUBLIC;
REVOKE ALL ON TABLE count_of_meters_not_in_mlh FROM postgres;
GRANT ALL ON TABLE count_of_meters_not_in_mlh TO postgres;
GRANT ALL ON TABLE count_of_meters_not_in_mlh TO sepgroup;
GRANT SELECT ON TABLE count_of_meters_not_in_mlh TO sepgroupreadonly;


--
-- Name: readings_after_uninstall; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE readings_after_uninstall FROM PUBLIC;
REVOKE ALL ON TABLE readings_after_uninstall FROM postgres;
GRANT ALL ON TABLE readings_after_uninstall TO postgres;
GRANT ALL ON TABLE readings_after_uninstall TO sepgroup;
GRANT SELECT ON TABLE readings_after_uninstall TO sepgroupreadonly;


--
-- Name: readings_before_install; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE readings_before_install FROM PUBLIC;
REVOKE ALL ON TABLE readings_before_install FROM postgres;
GRANT ALL ON TABLE readings_before_install TO postgres;
GRANT ALL ON TABLE readings_before_install TO sepgroup;
GRANT SELECT ON TABLE readings_before_install TO sepgroupreadonly;


--
-- Name: count_of_non_mlh_readings; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE count_of_non_mlh_readings FROM PUBLIC;
REVOKE ALL ON TABLE count_of_non_mlh_readings FROM postgres;
GRANT ALL ON TABLE count_of_non_mlh_readings TO postgres;
GRANT ALL ON TABLE count_of_non_mlh_readings TO sepgroup;
GRANT SELECT ON TABLE count_of_non_mlh_readings TO sepgroupreadonly;


--
-- Name: count_of_readings_and_meters_by_day; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE count_of_readings_and_meters_by_day FROM PUBLIC;
REVOKE ALL ON TABLE count_of_readings_and_meters_by_day FROM postgres;
GRANT ALL ON TABLE count_of_readings_and_meters_by_day TO postgres;
GRANT ALL ON TABLE count_of_readings_and_meters_by_day TO sepgroup;
GRANT SELECT ON TABLE count_of_readings_and_meters_by_day TO sepgroupreadonly;


--
-- Name: count_of_register_duplicates; Type: ACL; Schema: public; Owner: daniel
--

REVOKE ALL ON TABLE count_of_register_duplicates FROM PUBLIC;
REVOKE ALL ON TABLE count_of_register_duplicates FROM daniel;
GRANT ALL ON TABLE count_of_register_duplicates TO daniel;
GRANT ALL ON TABLE count_of_register_duplicates TO sepgroup;
GRANT SELECT ON TABLE count_of_register_duplicates TO sepgroupreadonly;


--
-- Name: dates_az_readings_channels_as_columns_new_spid; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_az_readings_channels_as_columns_new_spid FROM PUBLIC;
REVOKE ALL ON TABLE dates_az_readings_channels_as_columns_new_spid FROM eileen;
GRANT ALL ON TABLE dates_az_readings_channels_as_columns_new_spid TO eileen;
GRANT ALL ON TABLE dates_az_readings_channels_as_columns_new_spid TO sepgroup;
GRANT SELECT ON TABLE dates_az_readings_channels_as_columns_new_spid TO sepgroupreadonly;


--
-- Name: dates_egauge_energy_autoload; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_egauge_energy_autoload FROM PUBLIC;
REVOKE ALL ON TABLE dates_egauge_energy_autoload FROM eileen;
GRANT ALL ON TABLE dates_egauge_energy_autoload TO eileen;
GRANT ALL ON TABLE dates_egauge_energy_autoload TO sepgroup;
GRANT SELECT ON TABLE dates_egauge_energy_autoload TO sepgroupreadonly;


--
-- Name: dates_irradiance_data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_irradiance_data FROM PUBLIC;
REVOKE ALL ON TABLE dates_irradiance_data FROM eileen;
GRANT ALL ON TABLE dates_irradiance_data TO eileen;
GRANT ALL ON TABLE dates_irradiance_data TO sepgroup;
GRANT SELECT ON TABLE dates_irradiance_data TO sepgroupreadonly;


--
-- Name: dates_kihei_scada_temp_hum; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_kihei_scada_temp_hum FROM PUBLIC;
REVOKE ALL ON TABLE dates_kihei_scada_temp_hum FROM eileen;
GRANT ALL ON TABLE dates_kihei_scada_temp_hum TO eileen;
GRANT ALL ON TABLE dates_kihei_scada_temp_hum TO sepgroup;
GRANT SELECT ON TABLE dates_kihei_scada_temp_hum TO sepgroupreadonly;


--
-- Name: dates_meter_read; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_meter_read FROM PUBLIC;
REVOKE ALL ON TABLE dates_meter_read FROM eileen;
GRANT ALL ON TABLE dates_meter_read TO eileen;
GRANT ALL ON TABLE dates_meter_read TO sepgroup;
GRANT SELECT ON TABLE dates_meter_read TO sepgroupreadonly;


--
-- Name: dates_powermeterevents; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_powermeterevents FROM PUBLIC;
REVOKE ALL ON TABLE dates_powermeterevents FROM eileen;
GRANT ALL ON TABLE dates_powermeterevents TO eileen;
GRANT ALL ON TABLE dates_powermeterevents TO sepgroup;
GRANT SELECT ON TABLE dates_powermeterevents TO sepgroupreadonly;


--
-- Name: dates_tap_data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_tap_data FROM PUBLIC;
REVOKE ALL ON TABLE dates_tap_data FROM eileen;
GRANT ALL ON TABLE dates_tap_data TO eileen;
GRANT ALL ON TABLE dates_tap_data TO sepgroup;
GRANT SELECT ON TABLE dates_tap_data TO sepgroupreadonly;


--
-- Name: dates_transformer_data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE dates_transformer_data FROM PUBLIC;
REVOKE ALL ON TABLE dates_transformer_data FROM eileen;
GRANT ALL ON TABLE dates_transformer_data TO eileen;
GRANT ALL ON TABLE dates_transformer_data TO sepgroup;
GRANT SELECT ON TABLE dates_transformer_data TO sepgroupreadonly;


--
-- Name: deprecated_meter_ids_for_houses_without_pv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE deprecated_meter_ids_for_houses_without_pv FROM PUBLIC;
REVOKE ALL ON TABLE deprecated_meter_ids_for_houses_without_pv FROM postgres;
GRANT ALL ON TABLE deprecated_meter_ids_for_houses_without_pv TO postgres;
GRANT ALL ON TABLE deprecated_meter_ids_for_houses_without_pv TO sepgroup;
GRANT SELECT ON TABLE deprecated_meter_ids_for_houses_without_pv TO sepgroupreadonly;


--
-- Name: z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero FROM PUBLIC;
REVOKE ALL ON TABLE z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero FROM postgres;
GRANT ALL ON TABLE z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO postgres;
GRANT ALL ON TABLE z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO sepgroup;
GRANT SELECT ON TABLE z_dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO sepgroupreadonly;


--
-- Name: dz_count_of_fifteen_min_irradiance_intervals; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_count_of_fifteen_min_irradiance_intervals FROM PUBLIC;
REVOKE ALL ON TABLE dz_count_of_fifteen_min_irradiance_intervals FROM postgres;
GRANT ALL ON TABLE dz_count_of_fifteen_min_irradiance_intervals TO postgres;
GRANT ALL ON TABLE dz_count_of_fifteen_min_irradiance_intervals TO sepgroup;
GRANT SELECT ON TABLE dz_count_of_fifteen_min_irradiance_intervals TO sepgroupreadonly;


--
-- Name: dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero FROM PUBLIC;
REVOKE ALL ON TABLE dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero FROM postgres;
GRANT ALL ON TABLE dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO postgres;
GRANT ALL ON TABLE dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO sepgroup;
GRANT SELECT ON TABLE dz_avg_irradiance_uniform_fifteen_min_intervals_null_as_zero TO sepgroupreadonly;


--
-- Name: dz_energy_voltages_for_houses_without_pv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_energy_voltages_for_houses_without_pv FROM PUBLIC;
REVOKE ALL ON TABLE dz_energy_voltages_for_houses_without_pv FROM postgres;
GRANT ALL ON TABLE dz_energy_voltages_for_houses_without_pv TO postgres;
GRANT ALL ON TABLE dz_energy_voltages_for_houses_without_pv TO sepgroup;
GRANT SELECT ON TABLE dz_energy_voltages_for_houses_without_pv TO sepgroupreadonly;


--
-- Name: dz_irradiance_fifteen_min_intervals_plus_one_year; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_irradiance_fifteen_min_intervals_plus_one_year FROM PUBLIC;
REVOKE ALL ON TABLE dz_irradiance_fifteen_min_intervals_plus_one_year FROM postgres;
GRANT ALL ON TABLE dz_irradiance_fifteen_min_intervals_plus_one_year TO postgres;
GRANT ALL ON TABLE dz_irradiance_fifteen_min_intervals_plus_one_year TO sepgroup;
GRANT SELECT ON TABLE dz_irradiance_fifteen_min_intervals_plus_one_year TO sepgroupreadonly;


--
-- Name: dz_monthly_energy_summary_double_pv_meter; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_monthly_energy_summary_double_pv_meter FROM PUBLIC;
REVOKE ALL ON TABLE dz_monthly_energy_summary_double_pv_meter FROM postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_double_pv_meter TO postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_double_pv_meter TO sepgroup;
GRANT SELECT ON TABLE dz_monthly_energy_summary_double_pv_meter TO sepgroupreadonly;


--
-- Name: nonpv_service_point_ids; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE nonpv_service_point_ids FROM PUBLIC;
REVOKE ALL ON TABLE nonpv_service_point_ids FROM postgres;
GRANT ALL ON TABLE nonpv_service_point_ids TO postgres;
GRANT ALL ON TABLE nonpv_service_point_ids TO sepgroup;
GRANT SELECT ON TABLE nonpv_service_point_ids TO sepgroupreadonly;


--
-- Name: dz_monthly_energy_summary_for_nonpv_service_points; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_monthly_energy_summary_for_nonpv_service_points FROM PUBLIC;
REVOKE ALL ON TABLE dz_monthly_energy_summary_for_nonpv_service_points FROM postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_for_nonpv_service_points TO postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_for_nonpv_service_points TO sepgroup;
GRANT SELECT ON TABLE dz_monthly_energy_summary_for_nonpv_service_points TO sepgroupreadonly;


--
-- Name: dz_monthly_energy_summary_single_pv_meter; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_monthly_energy_summary_single_pv_meter FROM PUBLIC;
REVOKE ALL ON TABLE dz_monthly_energy_summary_single_pv_meter FROM postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_single_pv_meter TO postgres;
GRANT ALL ON TABLE dz_monthly_energy_summary_single_pv_meter TO sepgroup;
GRANT SELECT ON TABLE dz_monthly_energy_summary_single_pv_meter TO sepgroupreadonly;


--
-- Name: dz_nonpv_addresses_service_points; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_nonpv_addresses_service_points FROM PUBLIC;
REVOKE ALL ON TABLE dz_nonpv_addresses_service_points FROM postgres;
GRANT ALL ON TABLE dz_nonpv_addresses_service_points TO postgres;
GRANT ALL ON TABLE dz_nonpv_addresses_service_points TO sepgroup;
GRANT SELECT ON TABLE dz_nonpv_addresses_service_points TO sepgroupreadonly;


--
-- Name: nonpv_mlh; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE nonpv_mlh FROM PUBLIC;
REVOKE ALL ON TABLE nonpv_mlh FROM postgres;
GRANT ALL ON TABLE nonpv_mlh TO postgres;
GRANT ALL ON TABLE nonpv_mlh TO sepgroup;
GRANT SELECT ON TABLE nonpv_mlh TO sepgroupreadonly;


--
-- Name: dz_pv_interval_ids; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_pv_interval_ids FROM PUBLIC;
REVOKE ALL ON TABLE dz_pv_interval_ids FROM postgres;
GRANT ALL ON TABLE dz_pv_interval_ids TO postgres;
GRANT ALL ON TABLE dz_pv_interval_ids TO sepgroup;
GRANT SELECT ON TABLE dz_pv_interval_ids TO sepgroupreadonly;


--
-- Name: dz_pv_readings_in_nonpv_mlh; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_pv_readings_in_nonpv_mlh FROM PUBLIC;
REVOKE ALL ON TABLE dz_pv_readings_in_nonpv_mlh FROM postgres;
GRANT ALL ON TABLE dz_pv_readings_in_nonpv_mlh TO postgres;
GRANT ALL ON TABLE dz_pv_readings_in_nonpv_mlh TO sepgroup;
GRANT SELECT ON TABLE dz_pv_readings_in_nonpv_mlh TO sepgroupreadonly;


--
-- Name: dz_summary_pv_readings_in_nonpv_mlh; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE dz_summary_pv_readings_in_nonpv_mlh FROM PUBLIC;
REVOKE ALL ON TABLE dz_summary_pv_readings_in_nonpv_mlh FROM postgres;
GRANT ALL ON TABLE dz_summary_pv_readings_in_nonpv_mlh TO postgres;
GRANT ALL ON TABLE dz_summary_pv_readings_in_nonpv_mlh TO sepgroup;
GRANT SELECT ON TABLE dz_summary_pv_readings_in_nonpv_mlh TO sepgroupreadonly;


--
-- Name: eGauge_view_with_filters; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE "eGauge_view_with_filters" FROM PUBLIC;
REVOKE ALL ON TABLE "eGauge_view_with_filters" FROM eileen;
GRANT ALL ON TABLE "eGauge_view_with_filters" TO eileen;
GRANT ALL ON TABLE "eGauge_view_with_filters" TO sepgroup;
GRANT SELECT ON TABLE "eGauge_view_with_filters" TO sepgroupreadonly;


--
-- Name: egauge_energy_autoload_dates; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE egauge_energy_autoload_dates FROM PUBLIC;
REVOKE ALL ON TABLE egauge_energy_autoload_dates FROM postgres;
GRANT ALL ON TABLE egauge_energy_autoload_dates TO postgres;
GRANT ALL ON TABLE egauge_energy_autoload_dates TO sepgroup;
GRANT SELECT ON TABLE egauge_energy_autoload_dates TO sepgroupreadonly;


--
-- Name: event_data_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE event_data_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE event_data_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE event_data_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE event_data_id_seq TO sepgroupreadonly;


--
-- Name: event_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE event_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE event_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE event_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE event_id_seq TO sepgroupreadonly;


--
-- Name: event_table_view; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE event_table_view FROM PUBLIC;
REVOKE ALL ON TABLE event_table_view FROM eileen;
GRANT ALL ON TABLE event_table_view TO eileen;
GRANT ALL ON TABLE event_table_view TO sepgroup;
GRANT SELECT ON TABLE event_table_view TO sepgroupreadonly;


--
-- Name: interval_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE interval_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE interval_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE interval_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE interval_id_seq TO sepgroupreadonly;


--
-- Name: intervalreaddata_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE intervalreaddata_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE intervalreaddata_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE intervalreaddata_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE intervalreaddata_id_seq TO sepgroupreadonly;


--
-- Name: irradiance_data; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE irradiance_data FROM PUBLIC;
REVOKE ALL ON TABLE irradiance_data FROM eileen;
GRANT ALL ON TABLE irradiance_data TO eileen;
GRANT ALL ON TABLE irradiance_data TO sepgroup;
GRANT SELECT ON TABLE irradiance_data TO sepgroupreadonly;


--
-- Name: locations_with_pv_service_points_ids; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE locations_with_pv_service_points_ids FROM PUBLIC;
REVOKE ALL ON TABLE locations_with_pv_service_points_ids FROM postgres;
GRANT ALL ON TABLE locations_with_pv_service_points_ids TO postgres;
GRANT ALL ON TABLE locations_with_pv_service_points_ids TO sepgroup;
GRANT SELECT ON TABLE locations_with_pv_service_points_ids TO sepgroupreadonly;


--
-- Name: nonpv_mlh_v2; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE nonpv_mlh_v2 FROM PUBLIC;
REVOKE ALL ON TABLE nonpv_mlh_v2 FROM postgres;
GRANT ALL ON TABLE nonpv_mlh_v2 TO postgres;
GRANT ALL ON TABLE nonpv_mlh_v2 TO sepgroup;
GRANT SELECT ON TABLE nonpv_mlh_v2 TO sepgroupreadonly;


--
-- Name: meter_ids_for_service_points_without_pv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE meter_ids_for_service_points_without_pv FROM PUBLIC;
REVOKE ALL ON TABLE meter_ids_for_service_points_without_pv FROM postgres;
GRANT ALL ON TABLE meter_ids_for_service_points_without_pv TO postgres;
GRANT ALL ON TABLE meter_ids_for_service_points_without_pv TO sepgroup;
GRANT SELECT ON TABLE meter_ids_for_service_points_without_pv TO sepgroupreadonly;


--
-- Name: meterdata_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE meterdata_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE meterdata_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE meterdata_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE meterdata_id_seq TO sepgroupreadonly;


--
-- Name: monthly_energy_summary_all_meters; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE monthly_energy_summary_all_meters FROM PUBLIC;
REVOKE ALL ON TABLE monthly_energy_summary_all_meters FROM eileen;
GRANT ALL ON TABLE monthly_energy_summary_all_meters TO eileen;
GRANT ALL ON TABLE monthly_energy_summary_all_meters TO sepgroup;
GRANT SELECT ON TABLE monthly_energy_summary_all_meters TO sepgroupreadonly;


--
-- Name: monthly_energy_summary_houses_with_pv; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE monthly_energy_summary_houses_with_pv FROM PUBLIC;
REVOKE ALL ON TABLE monthly_energy_summary_houses_with_pv FROM eileen;
GRANT ALL ON TABLE monthly_energy_summary_houses_with_pv TO eileen;
GRANT ALL ON TABLE monthly_energy_summary_houses_with_pv TO sepgroup;
GRANT SELECT ON TABLE monthly_energy_summary_houses_with_pv TO sepgroupreadonly;


--
-- Name: name_address_service_point_id; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE name_address_service_point_id FROM PUBLIC;
REVOKE ALL ON TABLE name_address_service_point_id FROM eileen;
GRANT ALL ON TABLE name_address_service_point_id TO eileen;
GRANT ALL ON TABLE name_address_service_point_id TO sepgroup;
GRANT SELECT ON TABLE name_address_service_point_id TO sepgroupreadonly;


--
-- Name: power_meter_events_with_spid; Type: ACL; Schema: public; Owner: dave
--

REVOKE ALL ON TABLE power_meter_events_with_spid FROM PUBLIC;
REVOKE ALL ON TABLE power_meter_events_with_spid FROM dave;
GRANT ALL ON TABLE power_meter_events_with_spid TO dave;
GRANT ALL ON TABLE power_meter_events_with_spid TO sepgroup;
GRANT SELECT ON TABLE power_meter_events_with_spid TO sepgroupreadonly;


--
-- Name: pv_backup; Type: ACL; Schema: public; Owner: dave
--

REVOKE ALL ON TABLE pv_backup FROM PUBLIC;
REVOKE ALL ON TABLE pv_backup FROM dave;
GRANT ALL ON TABLE pv_backup TO dave;
GRANT ALL ON TABLE pv_backup TO sepgroup;
GRANT SELECT ON TABLE pv_backup TO sepgroupreadonly;


--
-- Name: pv_service_points_specifications_view; Type: ACL; Schema: public; Owner: eileen
--

REVOKE ALL ON TABLE pv_service_points_specifications_view FROM PUBLIC;
REVOKE ALL ON TABLE pv_service_points_specifications_view FROM eileen;
GRANT ALL ON TABLE pv_service_points_specifications_view TO eileen;
GRANT ALL ON TABLE pv_service_points_specifications_view TO sepgroup;
GRANT SELECT ON TABLE pv_service_points_specifications_view TO sepgroupreadonly;


--
-- Name: raw_meter_readings; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE raw_meter_readings FROM PUBLIC;
REVOKE ALL ON TABLE raw_meter_readings FROM postgres;
GRANT ALL ON TABLE raw_meter_readings TO postgres;
GRANT ALL ON TABLE raw_meter_readings TO sepgroup;
GRANT SELECT ON TABLE raw_meter_readings TO sepgroupreadonly;


--
-- Name: reading_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE reading_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE reading_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE reading_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE reading_id_seq TO sepgroupreadonly;


--
-- Name: readings_not_referenced_by_mlh; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE readings_not_referenced_by_mlh FROM PUBLIC;
REVOKE ALL ON TABLE readings_not_referenced_by_mlh FROM postgres;
GRANT ALL ON TABLE readings_not_referenced_by_mlh TO postgres;
GRANT ALL ON TABLE readings_not_referenced_by_mlh TO sepgroup;
GRANT SELECT ON TABLE readings_not_referenced_by_mlh TO sepgroupreadonly;


--
-- Name: readings_with_pv_service_point_id; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE readings_with_pv_service_point_id FROM PUBLIC;
REVOKE ALL ON TABLE readings_with_pv_service_point_id FROM postgres;
GRANT ALL ON TABLE readings_with_pv_service_point_id TO postgres;
GRANT ALL ON TABLE readings_with_pv_service_point_id TO sepgroup;
GRANT SELECT ON TABLE readings_with_pv_service_point_id TO sepgroupreadonly;


--
-- Name: register_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE register_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE register_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE register_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE register_id_seq TO sepgroupreadonly;


--
-- Name: registerdata_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE registerdata_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE registerdata_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE registerdata_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE registerdata_id_seq TO sepgroupreadonly;


--
-- Name: registerread_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE registerread_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE registerread_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE registerread_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE registerread_id_seq TO sepgroupreadonly;


--
-- Name: registers; Type: ACL; Schema: public; Owner: daniel
--

REVOKE ALL ON TABLE registers FROM PUBLIC;
REVOKE ALL ON TABLE registers FROM daniel;
GRANT ALL ON TABLE registers TO daniel;
GRANT ALL ON TABLE registers TO sepgroup;
GRANT SELECT ON TABLE registers TO sepgroupreadonly;


--
-- Name: test_AverageFifteenMinKiheiSCADATemperatureHumidity; Type: ACL; Schema: public; Owner: daniel
--

REVOKE ALL ON TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" FROM PUBLIC;
REVOKE ALL ON TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" FROM daniel;
GRANT ALL ON TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" TO daniel;
GRANT ALL ON TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" TO sepgroup;
GRANT SELECT ON TABLE "test_AverageFifteenMinKiheiSCADATemperatureHumidity" TO sepgroupreadonly;


--
-- Name: tier_id_seq; Type: ACL; Schema: public; Owner: sepgroup
--

REVOKE ALL ON SEQUENCE tier_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE tier_id_seq FROM sepgroup;
GRANT ALL ON SEQUENCE tier_id_seq TO sepgroup;
GRANT SELECT ON SEQUENCE tier_id_seq TO sepgroupreadonly;


--
-- PostgreSQL database dump complete
--

