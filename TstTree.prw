#INCLUDE 'PROTHEUS.CH'


User Function tdnXtree()
Local oGet
Local cGet := Space(6)
Local cDescri := Space(10)

Private ImgNok  := "LBNO"
Private ImgNok2 := "LBNO"

bDblClick:= {|oObjTree, nRow, nCol| U_TstTreeADblClick(oObjTree, nRow, nCol) }

 DEFINE DIALOG oDlg TITLE "Exemplo de XTree" FROM 0,0 TO 600,800 PIXEL

 //-------------------
 //Cria o objeto XTREE
 //-------------------
 oTree := xTree():New(000,000,300,300,oDlg,/*uChange*/,/*uRClick*/,bDblClick)

 //-------
 //Nível 1
 //-------
 oTree:AddTree("01",ImgNok,ImgNok2,"01",/*bAction*/,/*bRClick*/,/*bDblClick*/)
    //-------
    //Nível 2
    //-------
    oTree:AddTree("Teste",ImgNok,ImgNok2,"0101",/*bAction*/,/*bRClick*/,/*bDblClick*/)

    oTree:EndTree()

    oTree:AddTree("0101",ImgNok,ImgNok2,"0101",/*bAction*/,/*bRClick*/,/*bDblClick*/)

        //-------
        //Nível 3
        //-------

        oTree:AddTreeItem("0102",ImgNok,"0102",/*bAction*/,/*bRClick*/,/*bDblClick*/)

    oTree:EndTree()

    oTree:AddTree("0103",ImgNok,ImgNok2,"0103",/*bAction*/,/*bRClick*/,/*bDblClick*/)

    oTree:EndTree()

 oTree:EndTree()



 //---------------
 //Funcionalidades
 //---------------
 @ 000,340 GET oGet VAR cGet OF oDlg SIZE 40, 010 PIXEL
 TButton():New( 0,300 , "Seek Item", oDlg,{|| oTree:TreeSeek(AllTrim(cGet))},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )


 TButton():New( 010,300 , "Add Item", oDlg,{|| AddItem(oTree) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

 TButton():New( 020,300 , "Change BMP", oDlg,bDblClick,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

 @ 030,340 GET oGet1 VAR cDescri OF oDlg SIZE 40, 010 PIXEL
 TButton():New( 030,300 , "Altera Prompt", oDlg,{|| ChangePrompt(oTree,cDescri)},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

 TButton():New( 040,300 , "Info Pai", oDlg,{|| ShowFatherInfo(oTree)},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )


 ACTIVATE DIALOG oDlg CENTERED
Return

Static Function ChangePrompt(oTree,cDescri)

oTree:ChangePrompt(cDescri,oTree:GetCargo())

Return


Static Function AddItem(oTree)

If oTree:TreeSeek("0102")

 oTree:AddItem("Novo Item","0106",ImgNok,ImgNok2,2,/*bAction*/,/*bRClick*/,/*bDblClick*/)

 EndIf

Return



Static Function ShowFatherInfo(oTree)
Local aInfo := oTree:GetFatherNode()
Local cMessage

If Len(aInfo) > 0
 cMessage := "ID do Pai : " + aInfo[1] + CRLF
 cMessage += "ID : " + aInfo[2] + CRLF
 cMessage += "É nó? : " + IIf(aInfo[3],".T.",".F.") + CRLF
 cMessage += "cCargo : " + aInfo[4] + CRLF
 cMessage += "cResource1: " + aInfo[5] + CRLF
 cMessage += "cResource2: " + aInfo[6] + CRLF
 MsgInfo(cMessage,"Info do nó pai")
 EndIf

Return





//============================================================================\
/*/{Protheus.doc}TstTree
  ==============================================================================
    @description
    Testa a rotina de árvore do Protheus

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

/*/
//============================================================================\
User Function TstTree()

    Local nX,nY,nZ

    DEFINE DIALOG oDlg TITLE "Exemplo do PTSendTree" FROM 180,180 TO 550,700 PIXEL

    aNodes := {}

    IMAGE1  := "" 	// Imagem quando nível estiver fechado
    IMAGE2  := "" 	// Imagem quando nível estiver aberto
    nLoop   := 690  // Quantidade de Loops - irá gerar 20010 Itens
    nCount	:= 0	// Simula ID dos itens da Tree
    //cTime1 := Time()


    // EDT - AFC
    aAdd( aNodes, {"00", "0", "", "COL. BERTONI - ATENDIMENTO EVENTUAL", IMAGE1, IMAGE2} )

    // TAREFA - AF9
    aAdd( aNodes, {"01", "01", "", "ATENDIMENTO EVENTUAL", IMAGE1, IMAGE2} )


    // Estrutura
    aAdd( aNodes, {"02", "02", "", "FASE 01", IMAGE1, IMAGE2} )
    aAdd( aNodes, {"03", "2.01", "", "DOCUMENTACAO", IMAGE1, IMAGE2} )
    aAdd( aNodes, {"04", "2.01.01", "", "DESENVOLVER DOCUMENTACAO", IMAGE1, IMAGE2} )

    aAdd( aNodes, {"03", "02.02", "", "TESTES", IMAGE1, IMAGE2} )
    aAdd( aNodes, {"04", "02.02.01", "", "DESENHAR TESTES", IMAGE1, IMAGE2} )


    aAdd( aNodes, {"02", "02", "", "FASE 02", IMAGE1, IMAGE2} )

    aAdd( aNodes, {"02", "02", "", "FASE 03", IMAGE1, IMAGE2} )

/*
    // PRIMEIRO NÍVEL
    for nX := 1 to nLoop
    	nCount++
        IMAGE1 := "FOLDER5"
        aadd( aNodes, {'00', StrZero(nCount,7), "", "Primeiro Nível->ID: "+StrZero(nCount,7), IMAGE1, IMAGE2} )

        // SEGUNDO NÍVEL
        for nY := 1 to 7
        	nCount++
            IMAGE1 := "FOLDER6"
            aadd( aNodes, {'01', StrZero(nCount,7), "", "Segundo Nível->ID: "+StrZero(nCount,7), IMAGE1, IMAGE2} )

            // TERCEIRO NÍVEL
            for nZ := 1 to 3
            	nCount++
                IMAGE1 := "FOLDER10"
                aadd( aNodes, {'02',StrZero(nCount,7),"","Terceiro Nível->ID: "+StrZero(nCount,7), IMAGE1, IMAGE2} )
            next nZ

        next nY

    next nX */

    // Cria o objeto Tree
    oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)

    // Método para carga dos itens da Tree
    oTree:PTSendTree( aNodes )

    lClick:= .T.
    If lClick
        otree:BLDBLCLICK:= {|x1,x2,x3,x4,x5,x6,x6| U_TstTreeADblClick(x1,x2,x3,x4,x5,x6,x6) }
    EndIf

    ACTIVATE DIALOG oDlg CENTERED

Return ( Nil )
// FIM da Funcao TstTree
//==============================================================================



//============================================================================\
/*/{Protheus.doc}DblClick
  ==============================================================================
    @description
    Descrição da função

    @author Thiago Mota <mota.thiago@totvs.com.br>
    @version 1.0
    @since 22/01/2019

/*/
//============================================================================\
User Function TstTreeADblClick( par1, par2, par3, par4, par5, par6 )

    //Alert("OI")
    IMGNO:= "LBNO"
    IMGOK:= "LBTIK"
    NIVEL:= "01"
    oTree:ChangeBmp(IMGNO,IMGOK,NIVEL)

Return ( Nil )
// FIM da Funcao DblClick
//==============================================================================



