const express = require("express");
const router = express.Router();
const controller = require("../controllers/pacienteController");

router.post("/register", controller.cadastrarPaciente);

module.exports = router;
