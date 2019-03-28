#INCLUDE 'PROTHEUS.CH'

#DEFINE POS_FATHER  1
#DEFINE POS_CARGO   2
#DEFINE POS_PROMPT  3


//============================================================================\
/*/{Protheus.doc}UTree
==============================================================================
    @description
    Definição da classe UTree
    Tela de árvore com markbrowse, extende a classe xTree

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

    @obs
    Tentei fazer herança com a classe xTree, mas dá erro ao utilizar o construtor
    Mudei para composição

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
// FIM da Definição da classe UTree
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:New
==============================================================================
    @description
    Método construtor da classe UTree

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
// FIM do método New
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:AddPreItem
  ==============================================================================
    @description
    Adiciona item no Array de preparação, que será montado

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
// FIM do método AddPreItem
//==============================================================================



//============================================================================\
/*/{Protheus.doc}UTree:MountTree
  ==============================================================================
    @description
    Monta a Árvore a partir do Array de preparação

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 23/01/2019

/*/
//============================================================================\
METHOD MountTree() CLASS UTree

    // Organiza por Pai + Código
    aSort( ::aTreePre, , , { | x,y | ( Padr(x[POS_FATHER],20) + x[POS_CARGO] ) < ( Padr(y[POS_FATHER],20) + y[POS_CARGO] ) } )

    ::__Mount(::oXTree) // Monta a árvore

Return ( Nil )
// FIM do método MountTree
//==============================================================================



//============================================================================\
/*/{Protheus.doc}__Mount
  ==============================================================================
    @description
    Função recursiva para montagem da árvore

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
            // Se tiver elementos filhos, adiciona como árvore
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
    Marca ou Desmarca o item clicado, e trabalha a marcação dos pais e filhos

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

    @obs
    Características esperadas de comportamento:
    Se marcar/desmarcar o pai, todos os itens assumem o mesmo status

    Se marcar todos os itens de um Pai, este será marcado também
    Se desmarcar ao menos um item o Pai deixa de estar marcado.
    Estes dois comportamentos são extendidos para todos os níveis superiores


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

        // Busca todos os níveis superiores dos PAIs
        cFather:= oXTree:aNodes[nAscan][1]
        nFather:= Ascan( oXTree:aNodes, {|x| x[2] == cFather } )
        While nFather > 0

            If cMarca == ::cNoMark
                // Se o Pai está marcado e estou desmarcando, desmarca o Pai
                oXTree:ChangeBmp(cMarca,cMarca,oXTree:aCargo[nFather][1],lForce)
            Else
                // Se o Pai está desmarcado e todos os filhos estão marcados, marca o Pai
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

        // Se possui subníveis, marca recursivamente
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
// FIM da Função __MarkItem
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
    Teste e exemplo de utilização da classe

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

    /* Testa adição fora de ordem */
    oTree:AddPreItem("01.04","TAREFA 01.04","01")
    oTree:AddPreItem("01.05","TAREFA 01.05","01")
    oTree:AddPreItem("01.06","TAREFA 01.06","01")
    oTree:AddPreItem("01.07","TAREFA 01.07","01")
    oTree:AddPreItem("01.08","TAREFA 01.08","01")
    oTree:AddPreItem("01.09","TAREFA 01.09","01")

    oTree:AddPreItem("01.01","TAREFA 01.01","01")
    oTree:AddPreItem("01.02","TAREFA 01.02","01")

    /* Testa adição fora de ordem */
    oTree:AddPreItem("01.01.01.AAAA","TAREFA 01.01.01.AAAA","01.08.03")
    oTree:AddPreItem("01.08.03","TAREFA 01.08.03","01.08")

    /* Testa adição em Ordem */
    oTree:AddPreItem("01.03","TAREFA 01.03","01")
        oTree:AddPreItem("01.03.01","TAREFA 01.03.01","01.03")
        oTree:AddPreItem("01.03.02","TAREFA 01.03.02","01.03")
            oTree:AddPreItem("01.03.02.01","TAREFA 01.03.02.01","01.03.02")
            oTree:AddPreItem("01.03.02.02","TAREFA 01.03.02.02","01.03.02")
        oTree:AddPreItem("01.03.03","TAREFA 01.03.03","01.03")

    /* Testa adição fora de ordem */
         oTree:AddPreItem("01.08.02","TAREFA 01.08.02","01.08")
         oTree:AddPreItem("01.07.02","TAREFA 01.07.02","01.07")
         oTree:AddPreItem("01.04.02","TAREFA 01.04.02","01.04")

    oTree:MountTree()

    ACTIVATE DIALOG oDlg CENTERED

Return ( Nil )
// FIM da Funcao TSTUTree
//==============================================================================


