#include <iostream>
#include <string>
#include <vector>

using namespace std;

// creating a linked list;

template <class t>



class stack {
	struct Node 
	{
		t data;
		Node* link;

		// Constructor
		Node(int n)
		{
			this->data = n;
			this->link = NULL;
		}
	};
	Node* head;
    int SIZE ;

public:
	stack() 
    {
         head = NULL; 
         SIZE = 0  ;
    }


	void push(t data)
	{

		// Create new node temp and allocate memory in heap
		Node* temp = new Node(data);

		// Check if stack (heap) is full.
		// Then inserting an element would
		// lead to stack overflow
		if (!temp) {
			cout << "\nStack Overflow";
			exit(1);
		}

		// Initialize data into temp data field
		temp->data = data;

		// Put head pointer reference into temp link
		temp->link = head;

		// Make temp as head of Stack
		head = temp;
        SIZE++; 
	}

	// Utility function to check if
	// the stack is empty or not
	bool empty()
	{
		// If head is NULL it means that
		// there are no elements are in stack
		return head == NULL;
	}

	// Utility function to return head element in a stack
	int top()
	{
		// If stack is not empty , return the head element
		if (!empty())
			return head->data;
		else
			exit(1);
	}

	// Function to remove
	// a key from given queue q
	void pop()
	{
		Node* temp;

		// Check for stack underflow
		if (head == NULL) {
			cout << "\nStack Underflow" << endl;
			exit(1);
		}
		else {

			// Assign head to temp
			temp = head;

			// Assign second node to head
			head = head->link;

            SIZE--; 
			// This will automatically destroy
			// the link between first node and second node

			// Release memory of head node
			// i.e delete the node
			free(temp);
		}
	}
  int size()
  {
    return SIZE; 
  }

	// Function to print all the
	// elements of the stack
	void display()
	{
		Node* temp;

		// Check for stack underflow
		if (head == NULL) {
			cout << "\nStack Underflow";
			exit(1);
		}
		else {
			temp = head;
			while (temp != NULL) {

				// Print node data
				cout << temp->data;

				// Assign temp link to temp
				temp = temp->link;
				if (temp != NULL)
					cout << " -> ";
			}
		}
	}
};



// end of stack class 
int Priority(char c)
{
  if (c == '-' || c == '+')
    return 1;
  else if (c == '*' || c == '/')
    return 2;
  else if (c == '^')
    return 3;
  else
    return 0;
}
vector<string> infix_to_postfix(string exp)
{
  stack<char> stk;
  vector<string> output;
  int temp1 = 0;
  for (int i = 0; i < exp.length(); i++)
  {
    if (exp[i] == ' ')
      continue;
    if (isdigit(exp[i]))
    {
      while (isdigit(exp[i]))
      {
        int c = exp[i] - '0';
        temp1 = temp1 * 10 + c;
        i++;
      }
      i--;
      string val = to_string(temp1);
      output.push_back(val);
      temp1 = 0;
    }
    else if (exp[i] == '(')
      stk.push('(');
    else if (exp[i] == ')')
    {
      while (stk.top() != '(')
      {
        string xx = string(1, stk.top());
        output.push_back(xx);
        stk.pop();
      }
      stk.pop();
    }
    else
    {
      while (!stk.empty() && Priority(exp[i]) <= Priority(stk.top()))
      {
        if (exp[i] == '^' && stk.top() == '^')
          break;
        string xx = string(1, stk.top());
        output.push_back(xx);
        stk.pop();
      }
      stk.push(exp[i]);
    }
  }
  while (!stk.empty())
  {
    string xx = string(1, stk.top());
    output.push_back(xx);
    stk.pop();
  }
  return output;
}
bool is_operator(string s)
{
  if (s.size())
    return 0;
  char c = s[0];
  return (c == '+') || (c == '-') || (c == '*') || (c == '/') || (c == '^');
}
bool is_operator(char c)
{
  return (c == '+') || (c == '-') || (c == '*') || (c == '/') || (c == '^');
}
long long string_to_int(string s)
{
  long long val = 0;
  for (char i : s)
  {
    val = val * 10 + (i - '0');
  }
  return val;
}
int power(int a, int b)
{
  // return a ^b
  int value = 1;
  for (int i = 0; i < b; i++)
  {
    value *= a;
  }
  return value;
}
double make_operation(double a, double b, char op)
{
  double val = 0;
  switch (op)
  {
  case '+':
    val = a + b;
    break;
  case '-':
    val = a - b;
    break;
  case '/':
    val = a / b;
    break;
  case '*':
    val = a * b;
    break;

  case '^':
    val = power(a, b);
  default:
    break;
  }
  return val;
}
double Evaluation(vector<string> v)
{

  stack<double> st;
  for (int i = 0; i < v.size(); i++) {
    if (is_operator(v[i][0])) {
  
        int b = st.top();
        st.pop();

        int a = st.top();
        st.pop();
        double val = make_operation(a, b, v[i][0]);
        st.push(val);
      }
    
    else {
      int val = string_to_int(v[i]);
      st.push(val);
    }
  }
  
    return st.top();
  
}

string to_standard_infix(string s)
{
  string res = "";
  if (s[0] == '-')
    res += "(0-1)*";
  else if (s[0] != '+')
    res += s[0];

  for (int i = 1; i < s.size(); i++) {
    // 5 *+2 = > 5 *2 remove unwanted +ve sign
    if (s[i] == '+' && is_operator(s[i - 1]))
      continue;
    //          7(6) => 7*(6)              ||       (5)(8) = > (5)*(8)
    if ((s[i] == '(' && isdigit(s[i - 1])) || (s[i] == '(' && s[i - 1] == ')'))
      res += '*';
    if (s[i] == '-' && is_operator(s[i - 1])) {
      if (s[i - 1] == '/')
        res += "(0-1)/";      //  5*-2 = 5*(0-1)*2
      else
        res += "(0-1)*";      //  5/-2 = 5/(0-1)/2
    }
    else if (s[i] == '-' && s[i - 1] == '(')
      res += "(0-1)*";        // (-2) = ((0-1)*2)
    else
      res += s[i];
  }
  return res;
}

bool validParenthesis(string s)
{
  int cnt = 0;
  for (char c : s) {
    if (c == '(')
      cnt++;
    else if (c == ')')
      cnt--;
    if (cnt < 0)
      return false;
  }
  if (cnt)
    return false;
  return true;
}
bool isValidExpression(string s)
{
  if (!validParenthesis(s))
    return false;
  int prev = -1; // 1 for digits , 2 for operators , 3 for '('  , 4 for ')'
  for (char c : s) {
    if (c == '(') {
      if (prev == 4 || prev == 1)
        return false;
      prev = 3;
    }
    else if (c == ')') {
      // if exp[0] == ')' || () return false
      if (prev == -1 || prev == 3)
        return false;
      prev = 4;
    }
    else if (isdigit(c)) {
      // if )5 --> return false
      if (prev == 4)
        return false;
      prev = 1;
    }
    else if (c == '-' || c == '+' || c == '*' || c == '/') {
      if (prev == -1 || prev == 2 || prev == 3)
        return false;
      prev = 2;
    }
  }
  if (prev == 3 || prev == 2)
    return false;
  return true;
}
int main()
{
  // Enter the Expressoin to compute
  string infixExpression;
  cout << "Enter infixExpression : ";
  getline(cin, infixExpression);

  // Convert the input expression
  string standard_expression = to_standard_infix(infixExpression);

  if (!isValidExpression(standard_expression))
    return !(cout << "invalid Expression\n");

  // print the Standard Expression
  cout << "Standard Expression : " << standard_expression << "\n";

  // get the postfix from infix
  vector<string> postfix_expression = infix_to_postfix(standard_expression);

  // print the postfix Expression
  cout << "postfix Expression = : ";
  for (int i = 0; i < postfix_expression.size(); i++)
    cout << postfix_expression[i];
  cout << "\n";

  // get the value of the expreesion
  long long value = Evaluation(postfix_expression);
  cout << "Value : " << fixed << value << endl;
}

