'use strict'

const express = require('express')
const { btcUsd } = require('../controllers/rates')
const { checkToken } = require('../middleware/check')
const router = express.Router()

router.route('/btcusd')
    .get(checkToken, btcUsd)

module.exports = router
