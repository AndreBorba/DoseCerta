const express = require("express");
const router = express.Router();
const controller = require("../controllers/medicoController");

router.post("/register-medico", controller.cadastrarMedico);

module.exports = router;
