#INCLUDE 'PROTHEUS.CH'

#DEFINE POS_FATHER  1
#DEFINE POS_CARGO   2
#DEFINE POS_PROMPT  3


//============================================================================\
/*/{Protheus.doc}UTree
==============================================================================
    @description
    Defini��o da classe UTree
    Tela de �rvore com markbrowse, extende a classe xTree

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

    @obs
    Tentei fazer heran�a com a classe xTree, mas d� erro ao utilizar o construtor
    Mudei para composi��o

/*/
//============================================================================\
CLASS UTree /* FROM TTree */

    DATA oXTree     AS OBJECT
    DATA aTreePre   AS ARRAY
    DATA cMark      AS STRING
    DATA cNoMark    AS STRING

    METHOD New() CONSTRUCTOR
    METHOD AddPreItem()
    METHOD MountTree()
    METHOD __MarkItem()
    METHOD __Mount()

ENDCLASS
// FIM da Defini��o da classe UTree
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:New
==============================================================================
    @description
    M�todo construtor da classe UTree

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

/*/
//============================================================================\
METHOD New( nTop, nLeft, nWidth, nHeight, oOwner, uChange, uRClick, bDblClick, cMark, cNoMark ) CLASS UTree

    Default bDblClick:= {|oObj, nRow, nCol| ::__MarkItem(oObj) }
    Default cMark:= 'LBTIK'
    Default cNoMark:= 'LBNO'

    ::oXTree := xTree():New( nTop, nLeft, nWidth, nHeight, oOwner, uChange, uRClick, bDblClick )
    ::aTreePre:= {}

Return (Self)
// FIM do m�todo New
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:AddPreItem
  ==============================================================================
    @description
    Adiciona item no Array de prepara��o, que ser� montado

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 23/01/2019
/*/
//============================================================================\
METHOD AddPreItem(cCargo, cPrompt, cFather) CLASS UTree
    Default cFather:= ""
    Default ::aTreePre:= {}

    aAdd(::aTreePre, {cFather, cCargo, cPrompt})

Return ( Nil )
// FIM do m�todo AddPreItem
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:MountTree
  ==============================================================================
    @description
    Monta a �rvore a partir do Array de prepara��o

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 23/01/2019

/*/
//============================================================================\
METHOD MountTree() CLASS UTree

    // Organiza por Pai + C�digo
    aSort( ::aTreePre, , , { | x,y | ( Padr(x[POS_FATHER],20) + x[POS_CARGO] ) < ( Padr(y[POS_FATHER],20) + y[POS_CARGO] ) } )

    ::__Mount(::oXTree) // Monta a �rvore

Return ( Nil )
// FIM do m�todo MountTree
//==============================================================================



//============================================================================\
/*/{Protheus.doc}__Mount
  ==============================================================================
    @description
    Fun��o recursiva para montagem da �rvore

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 23/01/2019

/*/
//============================================================================\
METHOD __Mount( oTree, cFather ) CLASS UTree

    Local nX:= 1
    Local aItens
    Default cFather:= ::aTreePre[nX][POS_FATHER]

    aItens:= aFilter(::aTreePre,{|x| x[1] == cFather })

    While nX <= Len(aItens) .And. aItens[nX][POS_FATHER] == cFather

        If Ascan(::aTreePre, {|x| x[POS_FATHER] == aItens[nX][POS_CARGO] }) > 0
            // Se tiver elementos filhos, adiciona como �rvore
            oTree:AddTree(aItens[nX][POS_PROMPT], ::cNoMark,::cNoMark, aItens[nX][POS_CARGO])
            ::__Mount( oTree, aItens[nX][POS_CARGO] )
            oTree:EndTree()
        Else
            oTree:AddTreeItem(aItens[nX][POS_PROMPT],::cNoMark, aItens[nX][POS_CARGO] )
        EndIf
        nX++

    EndDo


Return ( Nil )
// FIM da Funcao __Mount
//==============================================================================



//============================================================================\
/*/{Protheus.doc}__MarkItem
  ==============================================================================
    @description
    Marca ou Desmarca o item clicado, e trabalha a marca��o dos pais e filhos

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

    @obs
    Caracter�sticas esperadas de comportamento:
    Se marcar/desmarcar o pai, todos os itens assumem o mesmo status

    Se marcar todos os itens de um Pai, este ser� marcado tamb�m
    Se desmarcar ao menos um item o Pai deixa de estar marcado.
    Estes dois comportamentos s�o extendidos para todos os n�veis superiores


/*/
//============================================================================\
METHOD __MarkItem(oXTree, cCargo, cMarca) CLASS UTree

    Local nAscan
    Local nChild
    Local nFather
    Local cFather
    Local nIni
    Local cId
    Local lForce:= .T.
    Local lAllMark
    Local cMarkFather
    Default cCargo:= oXTree:GetCargo()

    If oXTree:TreeSeek(cCargo) .And. ( nAscan := Ascan(oXTree:aCargo,{|x| x[1]==cCargo}) ) > 0

        Default cMarca:= If( oXTree:aNodes[nAscan][5] == ::cNoMark, ::cMark, ::cNoMark )
        oXTree:ChangeBmp(cMarca,cMarca,cCargo,lForce)

        // Busca todos os n�veis superiores dos PAIs
        cFather:= oXTree:aNodes[nAscan][1]
        nFather:= Ascan( oXTree:aNodes, {|x| x[2] == cFather } )
        While nFather > 0

            If cMarca == ::cNoMark
                // Se o Pai est� marcado e estou desmarcando, desmarca o Pai
                oXTree:ChangeBmp(cMarca,cMarca,oXTree:aCargo[nFather][1],lForce)
            Else
                // Se o Pai est� desmarcado e todos os filhos est�o marcados, marca o Pai
                nIni:= 1
                lAllMark:= .T.
                While lAllMark .And. ( nChild := Ascan(oXTree:aNodes,{|x| x[1] == cFather }, nIni) ) > 0
                    nIni:= nChild + 1
                    If oXTree:aNodes[nChild][5] == ::cNoMark
                        lAllMark:= .F.
                    EndIf
                EndDo
                cMarkFather:= If(lAllMark, ::cMark, ::cNoMark)
                oXTree:ChangeBmp(cMarkFather,cMarkFather,oXTree:aCargo[nFather][1],lForce)
            EndIf

            cFather:= oXTree:aNodes[nFather][1]
            nFather:= Ascan( oXTree:aNodes, {|x| x[2] == cFather } )

        EndDo

        // Se possui subn�veis, marca recursivamente
        If oXTree:aNodes[nAscan][3]
            nChild:= nAscan
            cId:= oXTree:aNodes[nChild][2]
            nIni:= 1

            While ( nChild := Ascan(oXTree:aNodes,{|x| x[1] == cId }, nIni) ) > 0
                nIni:= nChild + 1
                ::__MarkItem(oXTree, oXTree:aCargo[nChild][1], cMarca )
            EndDo

        EndIf

        oXTree:TreeSeek(cCargo)

    EndIf

Return ( Nil )
// FIM da Fun��o __MarkItem
//==============================================================================



//============================================================================\
/*/{Protheus.doc}aFilter
  ==============================================================================
    @description
    Filtra o Array Passado

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 23/01/2019

/*/
//============================================================================\
Static Function aFilter( aOrigem, bBloco )
    Local aDestino:= {}

    aEval(aOrigem, {|x| If(Eval(bBloco, x),aAdd(aDestino, x),Nil) })

Return ( aDestino )
// FIM da Funcao aFilter
//==============================================================================



//============================================================================\
/*/{Protheus.doc}TSTUTree
  ==============================================================================
    @description
    Teste e exemplo de utiliza��o da classe

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 24/01/2019

/*/
//============================================================================\
User Function TSTUTree( )

    DEFINE DIALOG oDlg TITLE "Exemplo de UTree" FROM 0,0 TO 600,800 PIXEL

    oTree := UTree():New(000,000,300,300,oDlg)

    //AddPreItem(cCargo, cPrompt, cFather)
    oTree:AddPreItem("01","EDT 0001","")

    /* Testa adi��o fora de ordem */
    oTree:AddPreItem("01.04","TAREFA 01.04","01")
    oTree:AddPreItem("01.05","TAREFA 01.05","01")
    oTree:AddPreItem("01.06","TAREFA 01.06","01")
    oTree:AddPreItem("01.07","TAREFA 01.07","01")
    oTree:AddPreItem("01.08","TAREFA 01.08","01")
    oTree:AddPreItem("01.09","TAREFA 01.09","01")

    oTree:AddPreItem("01.01","TAREFA 01.01","01")
    oTree:AddPreItem("01.02","TAREFA 01.02","01")

    /* Testa adi��o fora de ordem */
    oTree:AddPreItem("01.01.01.AAAA","TAREFA 01.01.01.AAAA","01.08.03")
    oTree:AddPreItem("01.08.03","TAREFA 01.08.03","01.08")

    /* Testa adi��o em Ordem */
    oTree:AddPreItem("01.03","TAREFA 01.03","01")
        oTree:AddPreItem("01.03.01","TAREFA 01.03.01","01.03")
        oTree:AddPreItem("01.03.02","TAREFA 01.03.02","01.03")
            oTree:AddPreItem("01.03.02.01","TAREFA 01.03.02.01","01.03.02")
            oTree:AddPreItem("01.03.02.02","TAREFA 01.03.02.02","01.03.02")
        oTree:AddPreItem("01.03.03","TAREFA 01.03.03","01.03")

    /* Testa adi��o fora de ordem */
         oTree:AddPreItem("01.08.02","TAREFA 01.08.02","01.08")
         oTree:AddPreItem("01.07.02","TAREFA 01.07.02","01.07")
         oTree:AddPreItem("01.04.02","TAREFA 01.04.02","01.04")

    oTree:MountTree()

    ACTIVATE DIALOG oDlg CENTERED

Return ( Nil )
// FIM da Funcao TSTUTree
//==============================================================================


