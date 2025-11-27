const express = require("express");
const router = express.Router();
const controller = require("../controllers/buscarController");

router.get("/buscar-paciente", controller.buscarPaciente);
router.get("/buscar-medico", controller.buscarMedico);

module.exports = router;
