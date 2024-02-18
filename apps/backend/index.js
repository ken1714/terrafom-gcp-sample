console.log('Server Start!');

const {Pool} = require('pg');
const dockerNames = require('docker-names');
const express = require('express');
const bodyParser = require('body-parser');

// .envから環境変数を読み込み
require('dotenv').config();

// Cloud SQLの接続情報
const dbConfig = {
    user    : process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host    : process.env.DB_HOST,
    database: process.env.DB_NAME,
    port    : process.env.DB_PORT
};

// テーブル設定
const MAX_ID  = 1 << 30;
const MAX_AGE = 100;
const TABLE_NAME = 'SampleTable'
const createTableQuery = `
CREATE TABLE IF NOT EXISTS
${TABLE_NAME} (
    id   INT         NOT NULL,
    name VARCHAR(50) NOT NULL,
    age  INT         NOT NULL,
    PRIMARY KEY (id)
    );
`;

function getRandomInt(maxValue) {
    return Math.floor(Math.random() * maxValue);
}

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.listen(process.env.PORT);

app.get('/api/get', function (req, res) {
    res.send({'message': 'Receive a Get request'});
    console.log('Receive a Get request');
})

app.post('/api/post', function (req, res) {
    res.send({'message': 'Receive a POST request as ' + req.body.text});
    console.log('Receive a POST request');
    console.log(req.body);
})

// TODO: postリクエストに変更すべき
app.get('/api/db', async (req, res) => {
    const pool = new Pool(dbConfig);

    let isConnected = false;
    try {
        const client = await pool.connect();
        isConnected = true;
    } catch(error) {
        isConnected = false;
    }

    // テーブル作成
    let isTableCreated = false;
    try {
        await pool.query('BEGIN');
        await pool.query(createTableQuery);
        await pool.query('COMMIT');
        isTableCreated = true;
    } catch(error) {
        isTableCreated = false;
    }

    // レコードの追加
    let isRecordInserted = false;
    try {
        await pool.query('BEGIN');
        await pool.query(`INSERT INTO ${TABLE_NAME} (id, name, age) VALUES (${getRandomInt(MAX_ID)}, '${dockerNames.getRandomName()}', ${getRandomInt(MAX_AGE)});`);
        await pool.query('COMMIT');
        isRecordInserted = true;
    } catch(error) {
        isRecordInserted = false;
    }
    res.send({isConnected, isTableCreated, isRecordInserted});
})
