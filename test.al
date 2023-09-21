int x[100], yam;

int main(void)
begin

	int i;
	int i2;

	read yam;

	write yam;
	write " is the base number. Calculation: 4 * i - yam\n\n";

	i = 0;
	i2 = 100;

	while i < 100 do 
	begin

		x[i] = 4 * i - yam;
		write x[i];
		
		if x[i] > 100 then
			write " bigger than 100!";

		write "\n";
		
		i = i + 1;


	end


end
