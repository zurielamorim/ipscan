#!/bin/bash

# Solicitar ao usuário para inserir manualmente o endereço IP da sub-rede
read -p "Insira o endereço IP da sub-rede (exemplo: 10.0.0.0/16): " subnet

# Verificar se o formato do endereço IP é válido
if [[ ! "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
    echo "Formato de endereço IP inválido. Por favor, insira um endereço válido."
    exit 1
fi

# Obter o diretório do script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Definir o caminho do arquivo de saída no mesmo diretório do script
output_file="$script_dir/resultado_scan.txt"

# Usar fping para identificar hosts ativos
hosts=$(fping -a -g $subnet)

# Salvar a lista de hosts ativos em um arquivo
echo "Informações Detalhadas:" > "$output_file"
for host in $hosts; do
    mac=$(arp -n $host | awk '{print $3}')
    
    # Usar o comando curl para consultar o banco de dados OUI da IEEE
    manufacturer_info=$(curl -s "https://macvendors.com/query/$mac")
    
    # Verificar se a resposta contém um campo "result" válido
    if [[ $manufacturer_info =~ "result" ]]; then
        company=$(echo "$manufacturer_info" | jq -r '.result.company')
        echo "IP: $host | MAC: $mac | Fabricante: $company" >> "$output_file"
    else
        echo "IP: $host | MAC: $mac | Fabricante: Informação não disponível" >> "$output_file"
    fi
done

echo "Resultados salvos em: $output_file"