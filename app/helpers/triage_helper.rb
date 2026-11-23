module TriageHelper
  def escala_spo2(atencion)
    atencion.usa_escala_spo2_2? ? "Escala 2" : "Escala 1"
  end

  # 36.8 → "36,8 °C" (la coma decimal sale del locale :es).
  def temperatura(valor)
    valor.present? ? "#{number_with_precision(valor, precision: 1)} °C" : ""
  end
end
