%FindKeyWord - Fun��o que procura por palavras chaves.
%
% Fun��o que retorna 1 se encontra a palavra chave ou  0 caso contr�rio.
% Essas palavras chaves s�o definidas nas fun��es:
%
% o ReadFEMFile;
% o ReadDEFFile.
%
% O significado de cada palavra chave pode ser melhor visualizado na
% documenta��o de cria��o dos arquivos .fem .def
%

function numb = FindKeyWord(string, fp)

vartudo = 0;
achou   = 0;
tam     = length(string);
cont    = 1;

while (cont == 1)
    pt = fgetl(fp);    % L� a linha do arquivo
    tam2 = length(pt); % Tamanho da string que est� sendo lida
    if (pt == -1)      % Checa condi��o de final de arquivo
        if (vartudo == 1)
            frewind(fp);% Volta para o in�cio do arquivo
            numb = 0;   % Retorna 0 se n�o encontra a palvra chave
            return
        else
            vartudo = 1;
            frewind(fp);
        end
    elseif (tam2 ~= 0)
        if(pt(1,1) == '*')
            if (strncmpi(pt, '*END', 4) == 1)
                if (vartudo == 1)
                    frewind(fp);
                    numb = 0; % Encontrou o fim do arquivo e n�o achou a palavra chave
                    return
                else
                    vartudo = 1;
                    frewind(fp); % Retorna para o in�cio do arquivo
                end
            elseif(strncmpi(pt, string, tam2) == 1 && tam == tam2)
                cont = 0;
                achou = 1;% Encontrou a palavra chave
            end
        end
    end
end
numb = achou; % Retorna 1, encontrou a palavra chave
