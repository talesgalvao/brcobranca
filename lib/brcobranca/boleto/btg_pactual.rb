# frozen_string_literal: true

module Brcobranca
  module Boleto
    class BtgPactual < Base
      def banco
        '208'
      end

      def banco_dv
        '1'
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

      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      def nosso_numero_boleto
        numero_documento.to_s.rjust(11, '0')
      end

      private

      def conta_corrente_dv
        conta_corrente.modulo11_9to2_10_como_x
      end
    end
  end
end
