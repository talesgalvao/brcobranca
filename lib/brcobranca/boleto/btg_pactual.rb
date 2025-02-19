# frozen_string_literal: true

module Brcobranca
  module Boleto
    class BtgPactual < Base
      def banco
        '208'
      end

      def codigo_barras_segunda_parte
        [
          agencia,
          carteira.to_s.rjust(2, '0'),
          numero_documento.to_s.rjust(11, '0'),
          conta_corrente.to_s.rjust(7, '0'),
          '0'
        ].join
      end
    end
  end
end
