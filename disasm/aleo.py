from .utils import *


def disasm_finalize_type(value: FinalizeType) -> str:
    match value.type:
        case FinalizeType.Type.Public:
            value: PublicFinalize
            return plaintext_type_to_str(value.plaintext_type) + ".public"
        case FinalizeType.Type.Record:
            value: RecordFinalize
            return str(value.identifier) + ".record"
        case FinalizeType.Type.ExternalRecord:
            raise NotImplementedError

def disasm_entry_type(value: EntryType) -> str:
    match value.type:
        case EntryType.Type.Constant:
            visibility = "constant"
        case EntryType.Type.Public:
            visibility = "public"
        case EntryType.Type.Private:
            visibility = "private"
        case _:
            raise ValueError("dead branch")
    return f"{plaintext_type_to_str(value.plaintext_type)}.{visibility}"

def disasm_register(value: Register) -> str:
    match value.type:
        case Register.Type.Locator:
            value: LocatorRegister
            return f"r{value.locator}"
        case Register.Type.Member:
            value: MemberRegister
            locator = f"r{value.locator}."
            identifiers = ".".join(map(str, value.identifiers))
            return locator + identifiers

def disasm_register_type(value: RegisterType) -> str:
    match value.type:
        case RegisterType.Type.Plaintext:
            value: PlaintextRegisterType
            return plaintext_type_to_str(value.plaintext_type)
        case RegisterType.Type.Record:
            value: RecordRegisterType
            return str(value.identifier) + ".record"
        case RegisterType.Type.ExternalRecord:
            value: ExternalRecordRegisterType
            return str(value.locator) + ".record"

def disasm_value_type(value: ValueType) -> str:
    match value.type:
        case ValueType.Type.Constant:
            value: ConstantValueType
            return plaintext_type_to_str(value.plaintext_type) + ".constant"
        case ValueType.Type.Public:
            value: PublicValueType
            return plaintext_type_to_str(value.plaintext_type) + ".public"
        case ValueType.Type.Private:
            value: PrivateValueType
            return plaintext_type_to_str(value.plaintext_type) + ".private"
        case ValueType.Type.Record:
            value: RecordValueType
            return str(value.identifier) + ".record"
        case ValueType.Type.ExternalRecord:
            value: ExternalRecordValueType
            return str(value.locator) + ".record"

def disasm_command(value: Command) -> str:
    match value.type:
        case Command.Type.Decrement:
            value: DecrementCommand
            decrement = value.decrement
            return f"decrement {decrement.mapping}[{disasm_operand(decrement.first)}] by {disasm_operand(decrement.second)}"
        case Command.Type.Instruction:
            value: InstructionCommand
            return disasm_instruction(value.instruction)
        case Command.Type.Increment:
            value: IncrementCommand
            increment = value.increment
            return f"increment {increment.mapping}[{disasm_operand(increment.first)}] by {disasm_operand(increment.second)}"

def disasm_literal(value: Literal) -> str:
    T = Literal.Type
    match value.type:
        case T.I8 | T.I16 | T.I32 | T.I64 | T.I128 | T.U8 | T.U16 | T.U32 | T.U64 | T.U128:
            return str(value.primitive) + value.type.name.lower()
        case T.Address:
            return aleo.bech32_encode("aleo", value.primitive.dump())
        case T.Field | T.Group | T.Scalar | T.Boolean:
            return str(value.primitive)
    raise NotImplementedError

def disasm_operand(value: Operand) -> str:
    match value.type:
        case Operand.Type.Literal:
            value: LiteralOperand
            return disasm_literal(value.literal)
        case Operand.Type.Register:
            value: RegisterOperand
            return disasm_register(value.register)
        case Operand.Type.ProgramID:
            value: ProgramIDOperand
            return str(value.program_id)
        case Operand.Type.Caller:
            return "self.caller"

def disasm_call_operator(value: CallOperator) -> str:
    match value.type:
        case CallOperator.Type.Locator:
            value: LocatorCallOperator
            return str(value.locator)
        case CallOperator.Type.Resource:
            value: ResourceCallOperator
            return str(value.resource)

def disasm_literals(value: Literals) -> str:
    operands = []
    for i in range(value.num_operands):
        operands.append(disasm_operand(value.operands[i]))
    return f"{' '.join(operands)} into {disasm_register(value.destination)}"

def disasm_assert(value: AssertInstruction) -> str:
    return " ".join(map(disasm_operand, value.operands))

def disasm_call(value: Call) -> str:
    return f"{disasm_call_operator(value.operator)} {' '.join(map(disasm_operand, value.operands))} into {' '.join(map(disasm_register, value.destinations))}"

def disasm_cast(value: Cast) -> str:
    return f"{' '.join(map(disasm_operand, value.operands))} into {disasm_register(value.destination)} as {disasm_register_type(value.register_type)}"

def disasm_instruction(value: Instruction) -> str:
    inst_str = f"{instruction_type_to_str(value.type)} "
    instruction_type = Instruction.type_map[value.type]
    if isinstance(instruction_type, Literals):
        return inst_str + disasm_literals(value.literals)
    if isinstance(instruction_type, AssertInstruction):
        return inst_str + disasm_assert(value.literals)
    if instruction_type is Call:
        return inst_str + disasm_call(value.literals)
    if instruction_type is Cast:
        return inst_str + disasm_cast(value.literals)

def disassemble_program(program: Program) -> str:
    res = disasm_str()
    for i in program.imports:
        i: Import
        res.insert_line(f"import {i.program_id};")
    res.insert_line("")
    res.insert_line(f"program {program.id};")
    res.insert_line("")
    for m in program.mappings.values():
        m: Mapping
        res.insert_line(f"mapping {m.name}:")
        res.indent()
        res.insert_line(f"key {m.key.name} as {disasm_finalize_type(m.key.finalize_type)};")
        res.insert_line(f"value {m.value.name} as {disasm_finalize_type(m.value.finalize_type)};")
        res.unindent()
        res.insert_line("")
    for i in program.interfaces.values():
        i: Interface
        res.insert_line(f"struct {i.name}:")
        res.indent()
        for m, t in i.members:
            res.insert_line(f"{m} as {plaintext_type_to_str(t)};")
        res.unindent()
        res.insert_line("")
    for r in program.records.values():
        r: RecordType
        res.insert_line(f"record {r.name}:")
        res.indent()
        res.insert_line(f"owner as address.{public_or_private_to_str(r.owner)};")
        res.insert_line(f"gates as u64.{public_or_private_to_str(r.gates)};")
        for identifier, entry in r.entries:
            res.insert_line(f"{identifier} as {disasm_entry_type(entry)};")
        res.unindent()
        res.insert_line("")
    for c in program.closures.values():
        c: Closure
        res.insert_line(f"closure {c.name}:")
        res.indent()
        for i in c.inputs:
            i: ClosureInput
            res.insert_line(f"input {disasm_register(i.register)} as {disasm_register_type(i.register_type)};")
        for i in c.instructions:
            i: Instruction
            res.insert_line(f"{disasm_instruction(i)};")
        for o in c.outputs:
            o: ClosureOutput
            res.insert_line(f"output {disasm_operand(o.operand)} as {disasm_register_type(o.register_type)};")
        res.unindent()
        res.insert_line("")
    for f in program.functions.values():
        f: Function
        res.insert_line(f"function {f.name}:")
        res.indent()
        for i in f.inputs:
            i: FunctionInput
            res.insert_line(f"input {disasm_register(i.register)} as {disasm_value_type(i.value_type)};")
        for i in f.instructions:
            i: Instruction
            res.insert_line(f"{disasm_instruction(i)};")
        for o in f.outputs:
            o: FunctionOutput
            res.insert_line(f"output {disasm_operand(o.operand)} as {disasm_value_type(o.value_type)};")
        if f.finalize.value is not None:
            finalize: Finalize
            finalize_command: FinalizeCommand
            finalize_command, finalize = f.finalize.value
            res.insert_line(f"finalize {' '.join(map(disasm_operand, finalize_command.operands))};")
            res.unindent()
            res.insert_line("")
            res.insert_line(f"finalize {finalize.name}:")
            res.indent()
            for i in finalize.inputs:
                i: FinalizeInput
                res.insert_line(f"input {disasm_register(i.register)} as {disasm_finalize_type(i.finalize_type)};")
            for i in finalize.instructions:
                i: Command
                res.insert_line(f"{disasm_command(i)};")
            for o in finalize.outputs:
                o: FinalizeOutput
                res.insert_line(f"output {disasm_operand(o.operand)} as {disasm_finalize_type(o.finalize_type)};")
        res.unindent()
        res.insert_line("")

    return str(res)