function hash(semilla, paso, N: Natural; p: Palabra): Natural;
var
   codigo: Natural;
   i: Integer;
begin
   codigo := semilla; // Inicializar el código con la semilla
   i := 1; // Inicializar el índice para recorrer la palabra

   // Recorrer la palabra p para calcular el código de hash
   while i <= p.tope do
   begin
      // Actualizar el código usando el paso y los caracteres de la palabra
      codigo := codigo * paso;
      codigo := codigo + ord(p.cadena[i]); // Sumar el valor ASCII del carácter

      // Incrementar el índice para avanzar al siguiente carácter
      i := i + 1;
     
   end;
    
   // Calcular el módulo N al final
   codigo := codigo mod N;

   // Devolver el código de hash resultante
   hash := codigo;
end;

function comparaPalabra(p1, p2: Palabra): Comparacion;
var
  i: Integer;
begin
  i := 1;
  
  while (i <= p1.tope) and (i <= p2.tope) do
  begin
    if p1.cadena[i] < p2.cadena[i] then
    begin
      comparaPalabra := menor;
      Exit; // Exit the function
    end
    else if p1.cadena[i] > p2.cadena[i] then
    begin
      comparaPalabra := mayor;
      Exit; // Exit the function
    end;
    i := i + 1;
  end;

  if p1.tope < p2.tope then
    comparaPalabra := menor
  else if p1.tope > p2.tope then
    comparaPalabra := mayor
  else
    comparaPalabra := igual;
end;

function mayorPalabraCant(pc1, pc2: PalabraCant): boolean;
begin
    
    if pc1.cant > pc2.cant then
        mayorPalabraCant := true  
    else if pc1.cant < pc2.cant then
        mayorPalabraCant := false  
    else
    begin 
        mayorPalabraCant := comparaPalabra(pc1.pal, pc2.pal) = mayor;
    end;
end;


procedure agregarOcurrencia (p: Palabra; var pals: Ocurrencias);
var
    nuevoNodo, iter, anterior: Ocurrencias;
begin
    nuevoNodo := NIL;
    iter := pals;
    anterior := NIL;

    
    while (iter <> NIL) and (comparaPalabra(p, iter^.palc.pal) <> igual) do
    begin
        anterior := iter;
        iter := iter^.sig;
    end;

    
    if iter <> NIL then
    begin
        iter^.palc.cant := iter^.palc.cant + 1;
    end
    else
    begin
        
        new(nuevoNodo);
        nuevoNodo^.palc.pal := p;
        nuevoNodo^.palc.cant := 1;
        nuevoNodo^.sig := NIL;

        
        if anterior = NIL then
            pals := nuevoNodo
        else
            anterior^.sig := nuevoNodo;
    end;
end;

procedure inicializarPredictor(var pred: Predictor);
var
    i: Integer;
begin
    {Inicializo todos los elementos de el array predicto a NIL}
    for i := 1 to MAXHASH do
        pred[i] := NIL;
end;

procedure entrenarPredictor(txt: Texto; var pred: Predictor);
var
    current, nextWord: Texto;
    hashIndex: Natural;
begin
    current := txt;
    nextWord := txt^.sig;

    while (current <> nil) and (nextWord <> nil) do
    begin
        // Obtener el hash para la palabra actual
        hashIndex := hash(SEMILLA, PASO, MAXHASH, current^.info);

        // Agregar la ocurrencia de la siguiente palabra en el predictor
        agregarOcurrencia(nextWord^.info, pred[hashIndex]);

        // Mover al siguiente par de palabras en el texto
        current := current^.sig;
        nextWord := nextWord^.sig;
    end;
end;


procedure Inter(var a, b: PalabraCant);
  var
    temp: PalabraCant;
begin
    temp := a;
    a := b;
    b := temp;
end;

procedure insOrdAlternativas(pc: PalabraCant; var alts: Alternativas);
var
    i: Integer;
begin
    { Verificar si pc puede ser insertada }
    if (alts.tope < MAXALTS) or mayorPalabraCant(pc, alts.pals[alts.tope]) then
    begin
        { Insertar pc al final de alts si es posible }
        if alts.tope < MAXALTS then
            alts.tope := alts.tope + 1;
            
              
        { Insertar pc si el tope sigue dentro de los límites }
        alts.pals[alts.tope] := pc;
  
        { Ordenar alts }
        i := alts.tope;
        while (i > 1) and mayorPalabraCant(alts.pals[i], alts.pals[i - 1]) do
        begin
            Inter(alts.pals[i], alts.pals[i - 1]);
            i := i - 1;
        end;
    end;
end;


procedure obtenerAlternativas(p: Palabra; pred: Predictor; var alts: Alternativas);
var
    hashIndex: Natural;
    iter: Ocurrencias;
begin
    { Inicializo la estructura de Alternativas}
    alts.tope := 0;

    { calculo el hash}
    hashIndex := hash(SEMILLA, PASO, MAXHASH, p);

    iter := pred[hashIndex];

    while (iter <> NIL)  do
    begin
        
        insOrdAlternativas(iter^.palc, alts);
        iter := iter^.sig;
    end;
end;

