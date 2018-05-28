{
  This file is part of ParsIMoS, a software for parsing input files for IMoS.

  Author
            Jean R. N. Haler - jean.haler@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  Developed with the beta testers
            Christopher Kune - c.kune@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)
            Dr. Johann Far - johann.far@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  Supervisor
            Prof. Edwin De Pauw - e.depauw@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  parsimos@outlook.com

—————————————————————————————————————————————
  Copyright (c) 2016-2017 University of Liège

  Licensed under the Apache License, Version 2.0 (the "License »); you may not use
  this file except in compliance with the License. You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software distributed
  under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the
  specific language governing permissions and limitations under the License.
—————————————————————————————————————————————
}

unit newsearchstring;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, StrUtils;

type

  { TForm2 }

  TForm2 = class(TForm)
    BtnDirectSelectLine: TButton;
    BtnSearch: TButton;
    BtnloadlastparamSearchTerms: TButton;
    BtnListSelectLine: TButton;
    BtnContinue: TButton;
    btnContwithMulliken: TButton;
    GroupBox1: TGroupBox;
    lblLBsearchterm: TLabel;
    lbldescription: TLabel;
    lbledtspacerlines: TLabeledEdit;
    lbledtnewlinenum: TLabeledEdit;
    lbledtchargecol: TLabeledEdit;
    lbledtidentifcol: TLabeledEdit;
    lbledtsearchlinenum: TLabeledEdit;
    lbledtsearchterm: TLabeledEdit;
    LBSearchTermLines: TListBox;
    procedure BtnContinueClick(Sender: TObject);
    procedure btnContwithMullikenClick(Sender: TObject);
    procedure BtnDirectSelectLineClick(Sender: TObject);
    procedure BtnListSelectLineClick(Sender: TObject);
    procedure BtnloadlastparamSearchTermsClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbledtsearchlinenumChange(Sender: TObject);
    procedure lbledtsearchtermChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    newsearchfirstline, newsearchcolatomid, newsearchcolatomcharg:integer;
    Resumeparsing, directlyMulliken:boolean;
  end;

var
  Form2: TForm2;

implementation

uses
  parsimos_unit;

{$R *.lfm}



{ TForm2 }

procedure TForm2.FormShow(Sender: TObject);                               //Load Default parameters for Mulliken & from ParsIMoS interface
begin
  lbledtsearchterm.Text:='';
  lbledtsearchlinenum.Text:='';
  LBSearchTermLines.Items.Clear;
  lblLBsearchterm.Hide;
  LBSearchTermLines.Hide;
  lbledtspacerlines.Hide;
  BtnListSelectLine.Hide;
  lbledtnewlinenum.Text:='';
  lbledtspacerlines.Text:='2';
  Form2.lbledtchargecol.Text:=Form1.lbledtatomchargcol.Text;
  Form2.lbledtidentifcol.Text:=Form1.lbledtatomidentcol.Text;
  Resumeparsing:=False;
  directlyMulliken:=False;
end;

procedure TForm2.lbledtsearchlinenumChange(Sender: TObject);
begin
  LBSearchTermLines.Items.Clear;
  lblLBsearchterm.Hide;
  LBSearchTermLines.Hide;
  lbledtspacerlines.Hide;
  BtnListSelectLine.Hide;
  lbledtsearchterm.Text:='';
end;

procedure TForm2.lbledtsearchtermChange(Sender: TObject);
begin
  lbledtsearchlinenum.Text:='';
end;

procedure TForm2.BtnSearchClick(Sender: TObject);                          //Search for the search term & the write associated lines in listbox
var
  searchstring:string;
  k:integer;
begin
  LBSearchTermLines.Items.Clear;
  lblLBsearchterm.Show;
  LBSearchTermLines.Show;
  lbledtspacerlines.Show;
  BtnListSelectLine.Show;

  searchstring:=Trim(lbledtsearchterm.Text);
  for k:=0 to (Form1.FileContents.Count-1) do
  begin
    if (AnsiContainsText(Trim(Form1.FileContents[k]),searchstring)=True) then
    begin
      LBSearchTermLines.Items.Add(IntToStr(k+1));
    end;
  end;
end;

procedure TForm2.BtnDirectSelectLineClick(Sender: TObject);                //Select the line from direct line input
begin
  lbledtnewlinenum.Text:=lbledtsearchlinenum.Text;
end;

procedure TForm2.BtnContinueClick(Sender: TObject);
var
  dir:string;
  Para: AnsiString;
  Param_searchterm_backup: text;
begin
  dir:=ProgramDirectory;                                 //directory of the inputs = directory of the .exe
  SetCurrentDir(dir);

  Para:='Last_parameters_searchterm.par';                //Backup of last parameters used for the new search terms
  AssignFile(Param_searchterm_backup, Para);
  Rewrite(Param_searchterm_backup);
  writeln(Param_searchterm_backup,'List of the parameters used for the last manual search term encoding.');
  writeln(Param_searchterm_backup,DateTimeToStr(Now));
  writeln(Param_searchterm_backup);                      //3 lines of comments
  writeln(Param_searchterm_backup,'Search Term:',chr(9),lbledtsearchterm.Text);
  writeln(Param_searchterm_backup,'Number of spacer lines:',chr(9),lbledtspacerlines.Text);
  writeln(Param_searchterm_backup,'Line number:',chr(9),lbledtsearchlinenum.Text);
  writeln(Param_searchterm_backup,'Atom charge column:',chr(9),lbledtchargecol.Text);
  writeln(Param_searchterm_backup,'Atom identifier column:',chr(9),lbledtidentifcol.Text);
  CloseFile(Param_searchterm_backup);

  if ((lbledtnewlinenum.Text='') or (lbledtidentifcol.Text='') or (lbledtchargecol.Text='')) then
  begin
    ShowMessage('Please encode ALL the new parsing parameters in the gray box.');
    Exit;
  end;

  newsearchfirstline:=StrToInt(lbledtnewlinenum.Text);                      //new variables (global) for continuing parsing
  newsearchcolatomcharg:=StrToInt(lbledtchargecol.Text);
  newsearchcolatomid:=StrToInt(lbledtidentifcol.Text);
  Resumeparsing:=True;
  Form2.Close;
end;

procedure TForm2.btnContwithMullikenClick(Sender: TObject);
begin
  directlyMulliken:=True;
  Form2.Close;
end;

procedure TForm2.BtnListSelectLineClick(Sender: TObject);                   //Select the line from the listbox + add number of lines between search term & begin of charges
var
  i:integer;
begin
  for i:=0 to (LBSearchTermLines.Items.Count-1) do
  begin
    if (LBSearchTermLines.Selected[i]=True) then
      lbledtnewlinenum.Text:=IntToStr(StrToInt(LBSearchTermLines.Items[i])+StrToInt(lbledtspacerlines.Text));
  end;
end;

procedure TForm2.BtnloadlastparamSearchTermsClick(Sender: TObject);        //Load last used parameters
var
  Paramfile:text;
  i,j,counter: integer;
  Params,List: TStringList;
  car,temp,res:string;
begin
  AssignFile(Paramfile,'Last_parameters_searchterm.par');                  //Backup of last parameters used for encoding
  Reset(Paramfile);                                                        //opens file; 3 lines of comments
  Params:= TStringList.Create;
  List:= TStringList.Create;
  Params.Clear;
  List.Clear;

  Params.LoadFromFile('Last_parameters_searchterm.par');
  j:=Params.Count-3;
  counter:=1;
  for i:=0 to (j-1) do
  begin
    res:='';
    car:=Copy(Params.Strings[i+3],counter,1);                              //3 lines of comments -> i+3
    while (car <> chr(9)) do
    begin
      counter:=counter+1;
      car:=Copy(Params.Strings[i+3],counter,1);
    end;
    while ((car=chr(9)) and ((counter+1)<=Length(Params.Strings[i+3]))) do
    begin
      counter:=counter+1;
      temp:=Copy(Params.Strings[i+3],counter,1);
      res:=res+temp;
    end;

    List.Add(res);
    counter:=1;
  end;

  lbledtsearchterm.Text:=List[0];
  lbledtspacerlines.Text:=List[1];
  lbledtsearchlinenum.Text:=List[2];
  lbledtchargecol.Text:=List[3];
  lbledtidentifcol.Text:=List[4];

  Params.Clear;
  List.Clear;
  Params.Free;
  List.Free;
  CloseFile(Paramfile);
end;

end.

