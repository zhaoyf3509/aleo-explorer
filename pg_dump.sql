--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2 (Debian 15.2-1)
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: explorer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA explorer;


--
-- Name: finalize_value_type; Type: TYPE; Schema: explorer; Owner: -
--

CREATE TYPE explorer.finalize_value_type AS ENUM (
    'Plaintext',
    'Record'
);


--
-- Name: transaction_type; Type: TYPE; Schema: explorer; Owner: -
--

CREATE TYPE explorer.transaction_type AS ENUM (
    'Deploy',
    'Execute'
);


--
-- Name: transition_data_type; Type: TYPE; Schema: explorer; Owner: -
--

CREATE TYPE explorer.transition_data_type AS ENUM (
    'Constant',
    'Public',
    'Private',
    'Record',
    'ExternalRecord'
);


--
-- Name: get_block_target_sum(bigint); Type: FUNCTION; Schema: explorer; Owner: -
--

CREATE FUNCTION explorer.get_block_target_sum(block_height bigint) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
SELECT SUM(target) FROM explorer.partial_solution ps
JOIN explorer.coinbase_solution cs ON cs.id = ps.coinbase_solution_id
JOIN explorer.block b ON b.id = cs.block_id
WHERE height = block_height
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _migration; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer._migration (
    migrated_id integer NOT NULL
);


--
-- Name: block; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.block (
    id integer NOT NULL,
    height bigint NOT NULL,
    block_hash text NOT NULL,
    previous_hash text NOT NULL,
    previous_state_root text NOT NULL,
    transactions_root text NOT NULL,
    coinbase_accumulator_point text NOT NULL,
    round numeric(20,0) NOT NULL,
    coinbase_target numeric(20,0) NOT NULL,
    proof_target numeric(20,0) NOT NULL,
    last_coinbase_target numeric(20,0) NOT NULL,
    last_coinbase_timestamp bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    signature text NOT NULL,
    coinbase_reward numeric(20,0)
);


--
-- Name: block_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.block_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: block_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.block_id_seq OWNED BY explorer.block.id;


--
-- Name: coinbase_solution; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.coinbase_solution (
    id integer NOT NULL,
    block_id integer NOT NULL,
    proof_x text NOT NULL,
    proof_y_positive boolean NOT NULL,
    target_sum numeric(20,0) DEFAULT 0 NOT NULL
);


--
-- Name: coinbase_solution_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.coinbase_solution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coinbase_solution_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.coinbase_solution_id_seq OWNED BY explorer.coinbase_solution.id;


--
-- Name: transaction_execute; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transaction_execute (
    id integer NOT NULL,
    transaction_id integer NOT NULL,
    global_state_root text NOT NULL,
    inclusion_proof text
);


--
-- Name: execute_transaction_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.execute_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: execute_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.execute_transaction_id_seq OWNED BY explorer.transaction_execute.id;


--
-- Name: fee; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.fee (
    id integer NOT NULL,
    transaction_id integer NOT NULL,
    global_state_root text NOT NULL,
    inclusion_proof text
);


--
-- Name: fee_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.fee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.fee_id_seq OWNED BY explorer.fee.id;


--
-- Name: leaderboard; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.leaderboard (
    address text NOT NULL,
    total_reward numeric(20,0) DEFAULT 0 NOT NULL,
    total_incentive numeric(20,0) DEFAULT 0 NOT NULL
);


--
-- Name: leaderboard_total; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.leaderboard_total (
    total_credit numeric(20,0) DEFAULT 0 NOT NULL
);


--
-- Name: partial_solution; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.partial_solution (
    id bigint NOT NULL,
    coinbase_solution_id integer NOT NULL,
    address text NOT NULL,
    nonce numeric(20,0) NOT NULL,
    commitment text NOT NULL,
    target numeric(20,0) NOT NULL,
    reward integer NOT NULL
);


--
-- Name: partial_solution_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.partial_solution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partial_solution_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.partial_solution_id_seq OWNED BY explorer.partial_solution.id;


--
-- Name: transition_input_private; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_input_private (
    id integer NOT NULL,
    transition_input_id integer NOT NULL,
    ciphertext_hash text NOT NULL,
    ciphertext text
);


--
-- Name: private_transition_input_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.private_transition_input_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: private_transition_input_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.private_transition_input_id_seq OWNED BY explorer.transition_input_private.id;


--
-- Name: program; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.program (
    id integer NOT NULL,
    transaction_deploy_id integer NOT NULL,
    program_id text NOT NULL,
    import text[],
    mapping text[],
    interface text[],
    record text[],
    closure text[],
    function text[],
    raw_data bytea NOT NULL
);


--
-- Name: program_function; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.program_function (
    id integer NOT NULL,
    program_id integer NOT NULL,
    name text NOT NULL,
    input text[] NOT NULL,
    input_mode text[] NOT NULL,
    output text[] NOT NULL,
    output_mode text[] NOT NULL,
    finalize text[] NOT NULL,
    called integer DEFAULT 0 NOT NULL
);


--
-- Name: program_function_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.program_function_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_function_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.program_function_id_seq OWNED BY explorer.program_function.id;


--
-- Name: program_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: program_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.program_id_seq OWNED BY explorer.program.id;


--
-- Name: transaction; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transaction (
    id integer NOT NULL,
    block_id integer NOT NULL,
    transaction_id text NOT NULL,
    type explorer.transaction_type NOT NULL,
    index integer NOT NULL
);


--
-- Name: transaction_deploy; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transaction_deploy (
    id integer NOT NULL,
    transaction_id integer NOT NULL,
    edition integer NOT NULL
);


--
-- Name: transaction_deployment_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transaction_deployment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_deployment_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transaction_deployment_id_seq OWNED BY explorer.transaction_deploy.id;


--
-- Name: transition_finalize_record; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_finalize_record (
    id integer NOT NULL,
    transition_finalize_id integer NOT NULL,
    record text NOT NULL
);


--
-- Name: transaction_finalize_record_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transaction_finalize_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_finalize_record_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transaction_finalize_record_id_seq OWNED BY explorer.transition_finalize_record.id;


--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transaction_id_seq OWNED BY explorer.transaction.id;


--
-- Name: transition; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition (
    id integer NOT NULL,
    transition_id text NOT NULL,
    transaction_execute_id integer,
    fee_id integer,
    program_id text NOT NULL,
    function_name text NOT NULL,
    proof text NOT NULL,
    tpk text NOT NULL,
    tcm text NOT NULL,
    fee bigint NOT NULL,
    index integer NOT NULL
);


--
-- Name: transition_finalize; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_finalize (
    id integer NOT NULL,
    transition_id integer NOT NULL,
    type explorer.finalize_value_type NOT NULL,
    index integer NOT NULL
);


--
-- Name: transition_finalize_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_finalize_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_finalize_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_finalize_id_seq OWNED BY explorer.transition_finalize.id;


--
-- Name: transition_finalize_plaintext; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_finalize_plaintext (
    id integer NOT NULL,
    transition_finalize_id integer NOT NULL,
    plaintext bytea NOT NULL
);


--
-- Name: transition_finalize_plaintext_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_finalize_plaintext_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_finalize_plaintext_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_finalize_plaintext_id_seq OWNED BY explorer.transition_finalize_plaintext.id;


--
-- Name: transition_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_id_seq OWNED BY explorer.transition.id;


--
-- Name: transition_input; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_input (
    id integer NOT NULL,
    transition_id integer NOT NULL,
    type explorer.transition_data_type NOT NULL,
    index integer NOT NULL
);


--
-- Name: transition_input_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_input_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_input_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_input_id_seq OWNED BY explorer.transition_input.id;


--
-- Name: transition_input_public; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_input_public (
    id integer NOT NULL,
    transition_input_id integer NOT NULL,
    plaintext_hash text NOT NULL,
    plaintext bytea
);


--
-- Name: transition_input_public_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_input_public_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_input_public_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_input_public_id_seq OWNED BY explorer.transition_input_public.id;


--
-- Name: transition_input_record; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_input_record (
    id integer NOT NULL,
    transition_input_id integer NOT NULL,
    serial_number text NOT NULL,
    tag text NOT NULL
);


--
-- Name: transition_input_record_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_input_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_input_record_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_input_record_id_seq OWNED BY explorer.transition_input_record.id;


--
-- Name: transition_output; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_output (
    id integer NOT NULL,
    transition_id integer NOT NULL,
    type explorer.transition_data_type NOT NULL,
    index integer NOT NULL
);


--
-- Name: transition_output_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_output_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_output_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_output_id_seq OWNED BY explorer.transition_output.id;


--
-- Name: transition_output_private; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_output_private (
    id integer NOT NULL,
    transition_output_id integer NOT NULL,
    ciphertext_hash text NOT NULL,
    ciphertext text
);


--
-- Name: transition_output_private_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_output_private_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_output_private_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_output_private_id_seq OWNED BY explorer.transition_output_private.id;


--
-- Name: transition_output_public; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_output_public (
    id integer NOT NULL,
    transition_output_id integer NOT NULL,
    plaintext_hash text NOT NULL,
    plaintext bytea
);


--
-- Name: transition_output_public_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_output_public_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_output_public_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_output_public_id_seq OWNED BY explorer.transition_output_public.id;


--
-- Name: transition_output_record; Type: TABLE; Schema: explorer; Owner: -
--

CREATE TABLE explorer.transition_output_record (
    id integer NOT NULL,
    transition_output_id integer NOT NULL,
    commitment text NOT NULL,
    checksum text NOT NULL,
    record_ciphertext text
);


--
-- Name: transition_output_record_id_seq; Type: SEQUENCE; Schema: explorer; Owner: -
--

CREATE SEQUENCE explorer.transition_output_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transition_output_record_id_seq; Type: SEQUENCE OWNED BY; Schema: explorer; Owner: -
--

ALTER SEQUENCE explorer.transition_output_record_id_seq OWNED BY explorer.transition_output_record.id;


--
-- Name: block id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.block ALTER COLUMN id SET DEFAULT nextval('explorer.block_id_seq'::regclass);


--
-- Name: coinbase_solution id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.coinbase_solution ALTER COLUMN id SET DEFAULT nextval('explorer.coinbase_solution_id_seq'::regclass);


--
-- Name: fee id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.fee ALTER COLUMN id SET DEFAULT nextval('explorer.fee_id_seq'::regclass);


--
-- Name: partial_solution id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.partial_solution ALTER COLUMN id SET DEFAULT nextval('explorer.partial_solution_id_seq'::regclass);


--
-- Name: program id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program ALTER COLUMN id SET DEFAULT nextval('explorer.program_id_seq'::regclass);


--
-- Name: program_function id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program_function ALTER COLUMN id SET DEFAULT nextval('explorer.program_function_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction ALTER COLUMN id SET DEFAULT nextval('explorer.transaction_id_seq'::regclass);


--
-- Name: transaction_deploy id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_deploy ALTER COLUMN id SET DEFAULT nextval('explorer.transaction_deployment_id_seq'::regclass);


--
-- Name: transaction_execute id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_execute ALTER COLUMN id SET DEFAULT nextval('explorer.execute_transaction_id_seq'::regclass);


--
-- Name: transition id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition ALTER COLUMN id SET DEFAULT nextval('explorer.transition_id_seq'::regclass);


--
-- Name: transition_finalize id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize ALTER COLUMN id SET DEFAULT nextval('explorer.transition_finalize_id_seq'::regclass);


--
-- Name: transition_finalize_plaintext id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_plaintext ALTER COLUMN id SET DEFAULT nextval('explorer.transition_finalize_plaintext_id_seq'::regclass);


--
-- Name: transition_finalize_record id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_record ALTER COLUMN id SET DEFAULT nextval('explorer.transaction_finalize_record_id_seq'::regclass);


--
-- Name: transition_input id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input ALTER COLUMN id SET DEFAULT nextval('explorer.transition_input_id_seq'::regclass);


--
-- Name: transition_input_private id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_private ALTER COLUMN id SET DEFAULT nextval('explorer.private_transition_input_id_seq'::regclass);


--
-- Name: transition_input_public id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_public ALTER COLUMN id SET DEFAULT nextval('explorer.transition_input_public_id_seq'::regclass);


--
-- Name: transition_input_record id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_record ALTER COLUMN id SET DEFAULT nextval('explorer.transition_input_record_id_seq'::regclass);


--
-- Name: transition_output id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output ALTER COLUMN id SET DEFAULT nextval('explorer.transition_output_id_seq'::regclass);


--
-- Name: transition_output_private id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_private ALTER COLUMN id SET DEFAULT nextval('explorer.transition_output_private_id_seq'::regclass);


--
-- Name: transition_output_public id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_public ALTER COLUMN id SET DEFAULT nextval('explorer.transition_output_public_id_seq'::regclass);


--
-- Name: transition_output_record id; Type: DEFAULT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_record ALTER COLUMN id SET DEFAULT nextval('explorer.transition_output_record_id_seq'::regclass);


--
-- Name: block block_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.block
    ADD CONSTRAINT block_pk PRIMARY KEY (id);


--
-- Name: coinbase_solution coinbase_solution_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.coinbase_solution
    ADD CONSTRAINT coinbase_solution_pk PRIMARY KEY (id);


--
-- Name: fee fee_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.fee
    ADD CONSTRAINT fee_pk PRIMARY KEY (id);


--
-- Name: leaderboard leaderboard_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.leaderboard
    ADD CONSTRAINT leaderboard_pk PRIMARY KEY (address);


--
-- Name: partial_solution partial_solution_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.partial_solution
    ADD CONSTRAINT partial_solution_pk PRIMARY KEY (id);


--
-- Name: program_function program_function_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program_function
    ADD CONSTRAINT program_function_pk PRIMARY KEY (id);


--
-- Name: program program_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program
    ADD CONSTRAINT program_pk PRIMARY KEY (id);


--
-- Name: transaction_deploy transaction_deployment_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_deploy
    ADD CONSTRAINT transaction_deployment_pk PRIMARY KEY (id);


--
-- Name: transaction_execute transaction_execute_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_execute
    ADD CONSTRAINT transaction_execute_pk PRIMARY KEY (id);


--
-- Name: transition_finalize_record transaction_finalize_record_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_record
    ADD CONSTRAINT transaction_finalize_record_pk PRIMARY KEY (id);


--
-- Name: transaction transaction_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction
    ADD CONSTRAINT transaction_pk PRIMARY KEY (id);


--
-- Name: transition_finalize transition_finalize_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize
    ADD CONSTRAINT transition_finalize_pk PRIMARY KEY (id);


--
-- Name: transition_finalize_plaintext transition_finalize_plaintext_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_plaintext
    ADD CONSTRAINT transition_finalize_plaintext_pk PRIMARY KEY (id);


--
-- Name: transition_input transition_input_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input
    ADD CONSTRAINT transition_input_pk PRIMARY KEY (id);


--
-- Name: transition_input_private transition_input_private_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_private
    ADD CONSTRAINT transition_input_private_pk PRIMARY KEY (id);


--
-- Name: transition_input_public transition_input_public_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_public
    ADD CONSTRAINT transition_input_public_pk PRIMARY KEY (id);


--
-- Name: transition_input_record transition_input_record_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_record
    ADD CONSTRAINT transition_input_record_pk PRIMARY KEY (id);


--
-- Name: transition_output transition_output_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output
    ADD CONSTRAINT transition_output_pk PRIMARY KEY (id);


--
-- Name: transition_output_private transition_output_private_pkey; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_private
    ADD CONSTRAINT transition_output_private_pkey PRIMARY KEY (id);


--
-- Name: transition_output_public transition_output_public_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_public
    ADD CONSTRAINT transition_output_public_pk PRIMARY KEY (id);


--
-- Name: transition_output_record transition_output_record_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_record
    ADD CONSTRAINT transition_output_record_pk PRIMARY KEY (id);


--
-- Name: transition transition_pk; Type: CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition
    ADD CONSTRAINT transition_pk PRIMARY KEY (id);


--
-- Name: block_block_hash_uindex; Type: INDEX; Schema: explorer; Owner: -
--

CREATE UNIQUE INDEX block_block_hash_uindex ON explorer.block USING btree (block_hash text_pattern_ops);


--
-- Name: block_height_uindex; Type: INDEX; Schema: explorer; Owner: -
--

CREATE UNIQUE INDEX block_height_uindex ON explorer.block USING btree (height);


--
-- Name: block_timestamp_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX block_timestamp_index ON explorer.block USING btree ("timestamp");


--
-- Name: coinbase_solution_block_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX coinbase_solution_block_id_index ON explorer.coinbase_solution USING btree (block_id);


--
-- Name: fee_transaction_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX fee_transaction_id_index ON explorer.fee USING btree (transaction_id);


--
-- Name: leaderboard_address_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX leaderboard_address_index ON explorer.leaderboard USING btree (address text_pattern_ops);


--
-- Name: leaderboard_total_incentive_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX leaderboard_total_incentive_index ON explorer.leaderboard USING btree (total_incentive);


--
-- Name: leaderboard_total_reward_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX leaderboard_total_reward_index ON explorer.leaderboard USING btree (total_reward);


--
-- Name: partial_solution_address_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX partial_solution_address_index ON explorer.partial_solution USING btree (address text_pattern_ops);


--
-- Name: partial_solution_coinbase_solution_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX partial_solution_coinbase_solution_id_index ON explorer.partial_solution USING btree (coinbase_solution_id);


--
-- Name: program_function_name_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX program_function_name_index ON explorer.program_function USING btree (name);


--
-- Name: program_function_program_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX program_function_program_id_index ON explorer.program_function USING btree (program_id);


--
-- Name: program_import_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX program_import_index ON explorer.program USING gin (import);


--
-- Name: program_program_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX program_program_id_index ON explorer.program USING btree (program_id text_pattern_ops);


--
-- Name: program_transaction_deploy_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX program_transaction_deploy_id_index ON explorer.program USING btree (transaction_deploy_id);


--
-- Name: transaction_block_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transaction_block_id_index ON explorer.transaction USING btree (block_id);


--
-- Name: transaction_deployment_transaction_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transaction_deployment_transaction_id_index ON explorer.transaction_deploy USING btree (transaction_id);


--
-- Name: transaction_execute_transaction_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transaction_execute_transaction_id_index ON explorer.transaction_execute USING btree (transaction_id);


--
-- Name: transaction_finalize_record_transaction_finalize_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transaction_finalize_record_transaction_finalize_id_index ON explorer.transition_finalize_record USING btree (transition_finalize_id);


--
-- Name: transaction_index_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transaction_index_index ON explorer.transaction USING btree (index);


--
-- Name: transaction_transaction_id_uindex; Type: INDEX; Schema: explorer; Owner: -
--

CREATE UNIQUE INDEX transaction_transaction_id_uindex ON explorer.transaction USING btree (transaction_id text_pattern_ops);


--
-- Name: transition_fee_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_fee_id_index ON explorer.transition USING btree (fee_id);


--
-- Name: transition_fee_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_fee_index ON explorer.transition USING btree (fee);


--
-- Name: transition_finalize_index_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_finalize_index_index ON explorer.transition_finalize USING btree (index);


--
-- Name: transition_finalize_plaintext_transition_finalize_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_finalize_plaintext_transition_finalize_id_index ON explorer.transition_finalize_plaintext USING btree (transition_finalize_id);


--
-- Name: transition_finalize_transition_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_finalize_transition_id_index ON explorer.transition_finalize USING btree (transition_id);


--
-- Name: transition_function_name_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_function_name_index ON explorer.transition USING btree (function_name);


--
-- Name: transition_index_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_index_index ON explorer.transition USING btree (index);


--
-- Name: transition_input_index_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_input_index_index ON explorer.transition_input USING btree (index);


--
-- Name: transition_input_private_transition_input_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_input_private_transition_input_id_index ON explorer.transition_input_private USING btree (transition_input_id);


--
-- Name: transition_input_public_transition_input_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_input_public_transition_input_id_index ON explorer.transition_input_public USING btree (transition_input_id);


--
-- Name: transition_input_record_transition_input_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_input_record_transition_input_id_index ON explorer.transition_input_record USING btree (transition_input_id);


--
-- Name: transition_input_transition_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_input_transition_id_index ON explorer.transition_input USING btree (transition_id);


--
-- Name: transition_output_index_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_output_index_index ON explorer.transition_output USING btree (index);


--
-- Name: transition_output_private_transition_output_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_output_private_transition_output_id_index ON explorer.transition_output_private USING btree (transition_output_id);


--
-- Name: transition_output_public_transition_output_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_output_public_transition_output_id_index ON explorer.transition_output_public USING btree (transition_output_id);


--
-- Name: transition_output_record_transition_output_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_output_record_transition_output_id_index ON explorer.transition_output_record USING btree (transition_output_id);


--
-- Name: transition_output_transition_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_output_transition_id_index ON explorer.transition_output USING btree (transition_id);


--
-- Name: transition_program_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_program_id_index ON explorer.transition USING btree (program_id);


--
-- Name: transition_transaction_execute_id_index; Type: INDEX; Schema: explorer; Owner: -
--

CREATE INDEX transition_transaction_execute_id_index ON explorer.transition USING btree (transaction_execute_id);


--
-- Name: transition_transition_id_uindex; Type: INDEX; Schema: explorer; Owner: -
--

CREATE UNIQUE INDEX transition_transition_id_uindex ON explorer.transition USING btree (transition_id text_pattern_ops);


--
-- Name: coinbase_solution coinbase_solution_block_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.coinbase_solution
    ADD CONSTRAINT coinbase_solution_block_id_fk FOREIGN KEY (block_id) REFERENCES explorer.block(id);


--
-- Name: fee fee_transaction_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.fee
    ADD CONSTRAINT fee_transaction_id_fk FOREIGN KEY (transaction_id) REFERENCES explorer.transaction(id);


--
-- Name: partial_solution partial_solution_coinbase_solution_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.partial_solution
    ADD CONSTRAINT partial_solution_coinbase_solution_id_fk FOREIGN KEY (coinbase_solution_id) REFERENCES explorer.coinbase_solution(id);


--
-- Name: program_function program_function_program_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program_function
    ADD CONSTRAINT program_function_program_id_fk FOREIGN KEY (program_id) REFERENCES explorer.program(id);


--
-- Name: program program_transaction_deployment_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.program
    ADD CONSTRAINT program_transaction_deployment_id_fk FOREIGN KEY (transaction_deploy_id) REFERENCES explorer.transaction_deploy(id);


--
-- Name: transaction transaction_block_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction
    ADD CONSTRAINT transaction_block_id_fk FOREIGN KEY (block_id) REFERENCES explorer.block(id);


--
-- Name: transaction_deploy transaction_deployment_transaction_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_deploy
    ADD CONSTRAINT transaction_deployment_transaction_id_fk FOREIGN KEY (transaction_id) REFERENCES explorer.transaction(id);


--
-- Name: transaction_execute transaction_execute_transaction_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transaction_execute
    ADD CONSTRAINT transaction_execute_transaction_id_fk FOREIGN KEY (transaction_id) REFERENCES explorer.transaction(id);


--
-- Name: transition_finalize_record transaction_finalize_record_transition_finalize_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_record
    ADD CONSTRAINT transaction_finalize_record_transition_finalize_id_fk FOREIGN KEY (transition_finalize_id) REFERENCES explorer.transition_finalize(id);


--
-- Name: transition transition_fee_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition
    ADD CONSTRAINT transition_fee_id_fk FOREIGN KEY (fee_id) REFERENCES explorer.fee(id);


--
-- Name: transition_finalize_plaintext transition_finalize_plaintext_transition_finalize_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize_plaintext
    ADD CONSTRAINT transition_finalize_plaintext_transition_finalize_id_fk FOREIGN KEY (transition_finalize_id) REFERENCES explorer.transition_finalize(id);


--
-- Name: transition_finalize transition_finalize_transition_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_finalize
    ADD CONSTRAINT transition_finalize_transition_id_fk FOREIGN KEY (transition_id) REFERENCES explorer.transition(id);


--
-- Name: transition_input_private transition_input_private_transition_input_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_private
    ADD CONSTRAINT transition_input_private_transition_input_id_fk FOREIGN KEY (transition_input_id) REFERENCES explorer.transition_input(id);


--
-- Name: transition_input_public transition_input_public_transition_input_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_public
    ADD CONSTRAINT transition_input_public_transition_input_id_fk FOREIGN KEY (transition_input_id) REFERENCES explorer.transition_input(id);


--
-- Name: transition_input_record transition_input_record_transition_input_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input_record
    ADD CONSTRAINT transition_input_record_transition_input_id_fk FOREIGN KEY (transition_input_id) REFERENCES explorer.transition_input(id);


--
-- Name: transition_input transition_input_transition_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_input
    ADD CONSTRAINT transition_input_transition_id_fk FOREIGN KEY (transition_id) REFERENCES explorer.transition(id);


--
-- Name: transition_output_private transition_output_private_transition_output_id_fkey; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_private
    ADD CONSTRAINT transition_output_private_transition_output_id_fkey FOREIGN KEY (transition_output_id) REFERENCES explorer.transition_output(id);


--
-- Name: transition_output_public transition_output_public_transition_output_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_public
    ADD CONSTRAINT transition_output_public_transition_output_id_fk FOREIGN KEY (transition_output_id) REFERENCES explorer.transition_output(id);


--
-- Name: transition_output_record transition_output_record_transition_output_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output_record
    ADD CONSTRAINT transition_output_record_transition_output_id_fk FOREIGN KEY (transition_output_id) REFERENCES explorer.transition_output(id);


--
-- Name: transition_output transition_output_transition_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition_output
    ADD CONSTRAINT transition_output_transition_id_fk FOREIGN KEY (transition_id) REFERENCES explorer.transition(id);


--
-- Name: transition transition_transaction_execute_id_fk; Type: FK CONSTRAINT; Schema: explorer; Owner: -
--

ALTER TABLE ONLY explorer.transition
    ADD CONSTRAINT transition_transaction_execute_id_fk FOREIGN KEY (transaction_execute_id) REFERENCES explorer.transaction_execute(id);


--
-- PostgreSQL database dump complete
--

